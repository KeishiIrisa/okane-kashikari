package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/okane-kashikari/backend/internal/middleware"
	"github.com/okane-kashikari/backend/internal/repository"
	"gorm.io/gorm"
)

type Contacts struct {
	repo *repository.Repository
}

func NewContacts(repo *repository.Repository) *Contacts {
	return &Contacts{repo: repo}
}

func (h *Contacts) List(c *gin.Context) {
	deviceID := middleware.GetDeviceID(c)
	list, err := h.repo.ListContacts(c.Request.Context(), deviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to list contacts"})
		return
	}
	c.JSON(http.StatusOK, list)
}

func (h *Contacts) Create(c *gin.Context) {
	var body struct {
		Name string `json:"name" binding:"required"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	deviceID := middleware.GetDeviceID(c)
	id, err := h.repo.CreateContact(c.Request.Context(), deviceID, body.Name)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create contact"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"id": id.String()})
}

func (h *Contacts) Update(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	var body struct {
		Name string `json:"name" binding:"required"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	deviceID := middleware.GetDeviceID(c)
	if err := h.repo.UpdateContact(c.Request.Context(), id, deviceID, body.Name); err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "contact not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update contact"})
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *Contacts) Delete(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	deviceID := middleware.GetDeviceID(c)
	if err := h.repo.DeleteContact(c.Request.Context(), id, deviceID); err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "contact not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete contact"})
		return
	}
	c.Status(http.StatusNoContent)
}
