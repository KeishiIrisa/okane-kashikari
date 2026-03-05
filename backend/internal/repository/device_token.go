package repository

import (
	"context"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm/clause"
)

func (r *Repository) UpsertDeviceToken(ctx context.Context, deviceID uuid.UUID, token, platform string) error {
	if r.db == nil {
		return nil
	}
	now := time.Now()
	row := DeviceToken{DeviceID: deviceID, Token: token, Platform: platform, CreatedAt: now, UpdatedAt: now}
	return r.db.WithContext(ctx).Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "device_id"}, {Name: "token"}},
		DoUpdates: clause.AssignmentColumns([]string{"platform", "updated_at"}),
	}).Create(&row).Error
}

// ListTokensByDeviceID は device_id に紐づく FCM トークン一覧を返す（バッチ用）
func (r *Repository) ListTokensByDeviceID(ctx context.Context, deviceID uuid.UUID) ([]string, error) {
	if r.db == nil {
		return nil, nil
	}
	var rows []DeviceToken
	if err := r.db.WithContext(ctx).Where("device_id = ?", deviceID).Find(&rows).Error; err != nil {
		return nil, err
	}
	tokens := make([]string, len(rows))
	for i := range rows {
		tokens[i] = rows[i].Token
	}
	return tokens, nil
}
