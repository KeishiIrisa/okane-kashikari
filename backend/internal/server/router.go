package server

import (
	"github.com/gin-gonic/gin"
	"github.com/okane-kashikari/backend/internal/config"
	"github.com/okane-kashikari/backend/internal/handler"
	"github.com/okane-kashikari/backend/internal/middleware"
	"github.com/okane-kashikari/backend/internal/repository"
)

func SetupRouter(r *gin.Engine, cfg *config.Config) {
	repo := repository.New(cfg.DatabaseURL)
	devices := handler.NewDevices(repo)
	contacts := handler.NewContacts(repo)
	transactions := handler.NewTransactions(repo)
	summary := handler.NewSummary(repo)
	deviceTokens := handler.NewDeviceTokens(repo)
	batchHandler := handler.NewBatch(cfg)

	internal := r.Group("/internal")
	internal.POST("/batch/due-date", batchHandler.DueDateNotifications)

	api := r.Group("/api")
	api.POST("/devices/register", devices.Register)

	apiWithDevice := api.Group("")
	apiWithDevice.Use(middleware.RequireDeviceID())
	{
		apiWithDevice.GET("/me", devices.Me)
		apiWithDevice.PUT("/me", devices.UpdateMe)
		apiWithDevice.GET("/contacts", contacts.List)
		apiWithDevice.POST("/contacts", contacts.Create)
		apiWithDevice.PUT("/contacts/:id", contacts.Update)
		apiWithDevice.DELETE("/contacts/:id", contacts.Delete)
		apiWithDevice.GET("/transactions", transactions.List)
		apiWithDevice.GET("/transactions/:id", transactions.Get)
		apiWithDevice.POST("/transactions", transactions.Create)
		apiWithDevice.PUT("/transactions/:id", transactions.Update)
		apiWithDevice.DELETE("/transactions/:id", transactions.Delete)
		apiWithDevice.POST("/transactions/:id/mark-paid", transactions.MarkPaid)
		apiWithDevice.GET("/summary", summary.Get)
		apiWithDevice.POST("/device/register", deviceTokens.Register)
	}
}
