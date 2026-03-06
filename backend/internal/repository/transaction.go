package repository

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// TransactionWithContact 一覧・取得用（JOIN 結果）
type TransactionWithContact struct {
	ID          uuid.UUID  `json:"id"`
	OwnerID     uuid.UUID  `json:"owner_id"`
	ContactID   uuid.UUID  `json:"contact_id"`
	Amount      int        `json:"amount"`
	Purpose     string     `json:"purpose"`
	Direction   string     `json:"direction"`
	DueDate     *time.Time `json:"due_date"`
	Status      string     `json:"status"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
	ContactName string     `json:"contact_name"`
}

func (r *Repository) ListTransactions(ctx context.Context, ownerID uuid.UUID, direction, status string, contactID *uuid.UUID) ([]TransactionWithContact, error) {
	if r.db == nil {
		return nil, nil
	}
	q := r.db.WithContext(ctx).Table("transactions t").
		Select("t.id, t.owner_id, t.contact_id, t.amount, t.purpose, t.direction, t.due_date, t.status, t.created_at, t.updated_at, c.name as contact_name").
		Joins("JOIN contacts c ON t.contact_id = c.id").
		Where("t.owner_id = ?", ownerID)
	if direction != "" {
		q = q.Where("t.direction = ?", direction)
	}
	if status != "" {
		q = q.Where("t.status = ?", status)
	}
	if contactID != nil {
		q = q.Where("t.contact_id = ?", *contactID)
	}
	q = q.Order("t.created_at DESC")
	var list []TransactionWithContact
	if err := q.Scan(&list).Error; err != nil {
		return nil, err
	}
	return list, nil
}

func (r *Repository) CreateTransaction(ctx context.Context, ownerID, contactID uuid.UUID, amount int, purpose, direction string, dueDate *time.Time) (uuid.UUID, error) {
	if r.db == nil {
		return uuid.New(), nil
	}
	tx := Transaction{
		OwnerID: ownerID, ContactID: contactID, Amount: amount, Purpose: purpose,
		Direction: direction, DueDate: dueDate, Status: "unpaid",
	}
	if err := r.db.WithContext(ctx).Create(&tx).Error; err != nil {
		return uuid.Nil, err
	}
	return tx.ID, nil
}

func (r *Repository) GetTransaction(ctx context.Context, id, ownerID uuid.UUID) (*TransactionWithContact, error) {
	if r.db == nil {
		return nil, nil
	}
	var t TransactionWithContact
	err := r.db.WithContext(ctx).Table("transactions t").
		Select("t.id, t.owner_id, t.contact_id, t.amount, t.purpose, t.direction, t.due_date, t.status, t.created_at, t.updated_at, c.name as contact_name").
		Joins("JOIN contacts c ON t.contact_id = c.id").
		Where("t.id = ? AND t.owner_id = ?", id, ownerID).Scan(&t).Error
	if errors.Is(err, gorm.ErrRecordNotFound) || (err == nil && t.ID == uuid.Nil) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &t, nil
}

func (r *Repository) UpdateTransaction(ctx context.Context, id, ownerID uuid.UUID, amount *int, purpose string, dueDate *time.Time, status string) error {
	if r.db == nil {
		return nil
	}
	updates := map[string]interface{}{}
	if amount != nil {
		updates["amount"] = *amount
	}
	if purpose != "" {
		updates["purpose"] = purpose
	}
	if dueDate != nil {
		updates["due_date"] = dueDate
	} else if status == "" {
		// allow clearing due_date when doing full update
		updates["due_date"] = nil
	}
	if status != "" {
		updates["status"] = status
	}
	if len(updates) == 0 {
		return nil
	}
	res := r.db.WithContext(ctx).Model(&Transaction{}).Where("id = ? AND owner_id = ?", id, ownerID).Updates(updates)
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *Repository) DeleteTransaction(ctx context.Context, id, ownerID uuid.UUID) error {
	if r.db == nil {
		return nil
	}
	res := r.db.WithContext(ctx).Where("id = ? AND owner_id = ?", id, ownerID).Delete(&Transaction{})
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *Repository) MarkTransactionPaid(ctx context.Context, id, ownerID uuid.UUID) error {
	return r.UpdateTransaction(ctx, id, ownerID, nil, "", nil, "paid")
}

// ListTransactionsDueToday は due_date が「今日」(UTC 日付) かつ status=unpaid の取引を返す（バッチ用）
func (r *Repository) ListTransactionsDueToday(ctx context.Context) ([]TransactionWithContact, error) {
	if r.db == nil {
		return nil, nil
	}
	var list []TransactionWithContact
	// 日本時間の「今日」で比較する場合: (due_date AT TIME ZONE 'UTC')::date = (now() AT TIME ZONE 'Asia/Tokyo')::date など
	// ここではサーバー日付で簡易に: DATE(due_date) = CURRENT_DATE
	err := r.db.WithContext(ctx).Table("transactions t").
		Select("t.id, t.owner_id, t.contact_id, t.amount, t.purpose, t.direction, t.due_date, t.status, t.created_at, t.updated_at, c.name as contact_name").
		Joins("JOIN contacts c ON t.contact_id = c.id").
		Where("t.status = ? AND t.due_date IS NOT NULL AND (t.due_date AT TIME ZONE 'Asia/Tokyo')::date = (now() AT TIME ZONE 'Asia/Tokyo')::date", "unpaid").
		Scan(&list).Error
	if err != nil {
		return nil, err
	}
	return list, nil
}
