package repository

import (
	"time"

	"github.com/google/uuid"
)

// Device 端末単位の疑似ユーザー (devices テーブル)
type Device struct {
	ID                 uuid.UUID `gorm:"type:uuid;primaryKey"`
	DefaultReminderMsg string    `gorm:"column:default_reminder_msg;not null;default:''"`
	CreatedAt          time.Time
	UpdatedAt          time.Time
}

func (Device) TableName() string { return "devices" }

// Contact 取引相手 (contacts テーブル)
type Contact struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	OwnerID    uuid.UUID `gorm:"type:uuid;not null;index"`
	Name       string    `gorm:"not null"`
	LastUsedAt time.Time `gorm:"not null"`
}

func (Contact) TableName() string { return "contacts" }

// Transaction 貸し借りデータ (transactions テーブル)
type Transaction struct {
	ID        uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	OwnerID   uuid.UUID  `gorm:"type:uuid;not null;index"`
	ContactID uuid.UUID  `gorm:"type:uuid;not null;index"`
	Amount    int        `gorm:"not null"`
	Purpose   *string    `gorm:""`
	Direction string     `gorm:"not null"`
	DueDate   *time.Time `gorm:""`
	Status    string     `gorm:"not null;default:unpaid"`
	CreatedAt time.Time
	UpdatedAt time.Time
}

func (Transaction) TableName() string { return "transactions" }

// DeviceToken FCM トークン (device_tokens テーブル)
type DeviceToken struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	DeviceID  uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:idx_device_token"`
	Token     string    `gorm:"not null;uniqueIndex:idx_device_token"`
	Platform  string    `gorm:"not null"`
	CreatedAt time.Time
	UpdatedAt time.Time
}

func (DeviceToken) TableName() string { return "device_tokens" }
