package main

import (
	"log"

	"github.com/okane-kashikari/backend/internal/config"
	"github.com/okane-kashikari/backend/internal/batch"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("config: %v", err)
	}
	if err := batch.RunDueDateNotifications(cfg); err != nil {
		log.Fatalf("batch: %v", err)
	}
	log.Println("batch completed")
}
