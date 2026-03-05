package repository

import (
	"github.com/google/uuid"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Repository struct {
	db *gorm.DB
}

func New(databaseURL string) *Repository {
	if databaseURL == "" {
		return &Repository{db: nil}
	}
	db, err := gorm.Open(postgres.Open(databaseURL), &gorm.Config{})
	if err != nil {
		panic(err)
	}
	return &Repository{db: db}
}

func (r *Repository) DB() *gorm.DB { return r.db }

func uuidPtr(u uuid.UUID) *uuid.UUID { return &u }
