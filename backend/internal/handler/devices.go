package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/okane-kashikari/backend/internal/middleware"
	"github.com/okane-kashikari/backend/internal/repository"
)

type Devices struct {
	repo *repository.Repository
}

func NewDevices(repo *repository.Repository) *Devices {
	return &Devices{repo: repo}
}

func (h *Devices) Register(c *gin.Context) {
	var body struct {
		DeviceID string `json:"device_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	id, err := uuid.Parse(body.DeviceID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid device_id format"})
		return
	}
	if err := h.repo.EnsureDevice(c.Request.Context(), id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to register device"})
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *Devices) Me(c *gin.Context) {
	deviceID := middleware.GetDeviceID(c)
	msg, err := h.repo.GetDevice(c.Request.Context(), deviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get device"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"default_reminder_msg": msg})
}

func (h *Devices) UpdateMe(c *gin.Context) {
	var body struct {
		DefaultReminderMsg string `json:"default_reminder_msg"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	deviceID := middleware.GetDeviceID(c)
	if err := h.repo.UpdateDeviceReminderMsg(c.Request.Context(), deviceID, body.DefaultReminderMsg); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update device"})
		return
	}
	c.Status(http.StatusNoContent)
}
