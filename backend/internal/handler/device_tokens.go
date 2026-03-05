package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/okane-kashikari/backend/internal/middleware"
	"github.com/okane-kashikari/backend/internal/repository"
)

type DeviceTokens struct {
	repo *repository.Repository
}

func NewDeviceTokens(repo *repository.Repository) *DeviceTokens {
	return &DeviceTokens{repo: repo}
}

func (h *DeviceTokens) Register(c *gin.Context) {
	var body struct {
		Token    string `json:"token" binding:"required"`
		Platform string `json:"platform" binding:"required,oneof=ios android"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	deviceID := middleware.GetDeviceID(c)
	if err := h.repo.UpsertDeviceToken(c.Request.Context(), deviceID, body.Token, body.Platform); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to register token"})
		return
	}
	c.Status(http.StatusNoContent)
}
