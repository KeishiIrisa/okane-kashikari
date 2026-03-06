package repository

import (
	"context"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ContactListItem 一覧用
type ContactListItem struct {
	ID         uuid.UUID `json:"id"`
	OwnerID    uuid.UUID `json:"owner_id"`
	Name       string    `json:"name"`
	LastUsedAt string    `json:"last_used_at"`
}

func (r *Repository) ListContacts(ctx context.Context, ownerID uuid.UUID) ([]ContactListItem, error) {
	if r.db == nil {
		return nil, nil
	}
	var list []Contact
	if err := r.db.WithContext(ctx).Where("owner_id = ?", ownerID).Order("last_used_at DESC").Find(&list).Error; err != nil {
		return nil, err
	}
	out := make([]ContactListItem, len(list))
	for i := range list {
		out[i] = ContactListItem{
			ID:         list[i].ID,
			OwnerID:    list[i].OwnerID,
			Name:       list[i].Name,
			LastUsedAt: list[i].LastUsedAt.Format("2006-01-02T15:04:05Z07:00"),
		}
	}
	return out, nil
}

func (r *Repository) CreateContact(ctx context.Context, ownerID uuid.UUID, name string) (uuid.UUID, error) {
	if r.db == nil {
		return uuid.New(), nil
	}
	c := Contact{OwnerID: ownerID, Name: name}
	if err := r.db.WithContext(ctx).Create(&c).Error; err != nil {
		return uuid.Nil, err
	}
	return c.ID, nil
}

func (r *Repository) UpdateContact(ctx context.Context, id, ownerID uuid.UUID, name string) error {
	if r.db == nil {
		return nil
	}
	res := r.db.WithContext(ctx).Model(&Contact{}).Where("id = ? AND owner_id = ?", id, ownerID).Update("name", name)
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *Repository) DeleteContact(ctx context.Context, id, ownerID uuid.UUID) error {
	if r.db == nil {
		return nil
	}
	res := r.db.WithContext(ctx).Where("id = ? AND owner_id = ?", id, ownerID).Delete(&Contact{})
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *Repository) TouchContactLastUsed(ctx context.Context, contactID uuid.UUID) error {
	if r.db == nil {
		return nil
	}
	return r.db.WithContext(ctx).Model(&Contact{}).Where("id = ?", contactID).Update("last_used_at", time.Now()).Error
}
