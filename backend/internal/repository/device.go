package repository

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

func (r *Repository) EnsureDevice(ctx context.Context, id uuid.UUID) error {
	if r.db == nil {
		return nil
	}
	return r.db.WithContext(ctx).Where("id = ?", id).FirstOrCreate(&Device{ID: id}).Error
}

func (r *Repository) GetDevice(ctx context.Context, id uuid.UUID) (defaultReminderMsg string, err error) {
	if r.db == nil {
		return "", nil
	}
	var d Device
	err = r.db.WithContext(ctx).Select("default_reminder_msg").Where("id = ?", id).First(&d).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return "", nil
	}
	if err != nil {
		return "", err
	}
	return d.DefaultReminderMsg, nil
}

func (r *Repository) UpdateDeviceReminderMsg(ctx context.Context, id uuid.UUID, msg string) error {
	if r.db == nil {
		return nil
	}
	return r.db.WithContext(ctx).Model(&Device{}).Where("id = ?", id).Update("default_reminder_msg", msg).Error
}
