package repository

import (
	"context"

	"github.com/google/uuid"
)

// SummaryResult ダッシュボード用集計
type SummaryResult struct {
	TotalLentUnpaid    int
	TotalBorrowedUnpaid int
	Recent             []TransactionWithContact
}

const recentTransactionsLimit = 10

func (r *Repository) GetSummary(ctx context.Context, ownerID uuid.UUID) (*SummaryResult, error) {
	if r.db == nil {
		return &SummaryResult{Recent: []TransactionWithContact{}}, nil
	}
	var lentSum, borrowedSum int
	r.db.WithContext(ctx).Model(&Transaction{}).Where("owner_id = ? AND direction = ? AND status = ?", ownerID, "LENT", "unpaid").Select("COALESCE(SUM(amount),0)").Scan(&lentSum)
	r.db.WithContext(ctx).Model(&Transaction{}).Where("owner_id = ? AND direction = ? AND status = ?", ownerID, "BORROWED", "unpaid").Select("COALESCE(SUM(amount),0)").Scan(&borrowedSum)
	recent, _ := r.ListTransactions(ctx, ownerID, "", "", nil)
	if len(recent) > recentTransactionsLimit {
		recent = recent[:recentTransactionsLimit]
	}
	return &SummaryResult{
		TotalLentUnpaid:    lentSum,
		TotalBorrowedUnpaid: borrowedSum,
		Recent:             recent,
	}, nil
}
