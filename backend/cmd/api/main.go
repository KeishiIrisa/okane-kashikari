package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/okane-kashikari/backend/internal/config"
	"github.com/okane-kashikari/backend/internal/server"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("config: %v", err)
	}
	r := gin.Default()
	server.SetupRouter(r, cfg)
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("API listening on :%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}
