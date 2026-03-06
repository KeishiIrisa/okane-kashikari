package handler

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/okane-kashikari/backend/internal/middleware"
	"github.com/okane-kashikari/backend/internal/repository"
	"gorm.io/gorm"
)

type Transactions struct {
	repo *repository.Repository
}

func NewTransactions(repo *repository.Repository) *Transactions {
	return &Transactions{repo: repo}
}

func (h *Transactions) Get(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	deviceID := middleware.GetDeviceID(c)
	tx, err := h.repo.GetTransaction(c.Request.Context(), id, deviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get transaction"})
		return
	}
	if tx == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "transaction not found"})
		return
	}
	c.JSON(http.StatusOK, tx)
}

func (h *Transactions) List(c *gin.Context) {
	deviceID := middleware.GetDeviceID(c)
	direction := c.Query("direction")
	status := c.Query("status")
	var contactID *uuid.UUID
	if s := c.Query("contact_id"); s != "" {
		if id, err := uuid.Parse(s); err == nil {
			contactID = &id
		}
	}
	list, err := h.repo.ListTransactions(c.Request.Context(), deviceID, direction, status, contactID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to list transactions"})
		return
	}
	c.JSON(http.StatusOK, list)
}

func (h *Transactions) Create(c *gin.Context) {
	var body struct {
		ContactID string  `json:"contact_id" binding:"required"`
		Amount    int     `json:"amount" binding:"required,gt=0"`
		Purpose   string  `json:"purpose" binding:"required"`
		Direction string  `json:"direction" binding:"required,oneof=LENT BORROWED"`
		DueDate   *string `json:"due_date"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	contactID, err := uuid.Parse(body.ContactID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid contact_id"})
		return
	}
	deviceID := middleware.GetDeviceID(c)
	var dueDate *time.Time
	if body.DueDate != nil && *body.DueDate != "" {
		t, err := time.Parse(time.RFC3339, *body.DueDate)
		if err != nil {
			t, err = time.Parse("2006-01-02", *body.DueDate)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "invalid due_date format"})
				return
			}
		}
		dueDate = &t
	}
	id, err := h.repo.CreateTransaction(c.Request.Context(), deviceID, contactID, body.Amount, body.Purpose, body.Direction, dueDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create transaction"})
		return
	}
	if err := h.repo.TouchContactLastUsed(c.Request.Context(), contactID); err != nil {
		// non-fatal
	}
	c.JSON(http.StatusCreated, gin.H{"id": id.String()})
}

func (h *Transactions) Update(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	var body struct {
		Amount   *int    `json:"amount"`
		Purpose  string  `json:"purpose"`
		DueDate  *string `json:"due_date"`
		Status   string  `json:"status"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	deviceID := middleware.GetDeviceID(c)
	var dueDate *time.Time
	if body.DueDate != nil && *body.DueDate != "" {
		t, err := time.Parse(time.RFC3339, *body.DueDate)
		if err != nil {
			t, _ = time.Parse("2006-01-02", *body.DueDate)
		}
		dueDate = &t
	}
	if err := h.repo.UpdateTransaction(c.Request.Context(), id, deviceID, body.Amount, body.Purpose, dueDate, body.Status); err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "transaction not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update transaction"})
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *Transactions) Delete(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	deviceID := middleware.GetDeviceID(c)
	if err := h.repo.DeleteTransaction(c.Request.Context(), id, deviceID); err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "transaction not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete transaction"})
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *Transactions) MarkPaid(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	deviceID := middleware.GetDeviceID(c)
	if err := h.repo.MarkTransactionPaid(c.Request.Context(), id, deviceID); err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "transaction not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to mark paid"})
		return
	}
	c.Status(http.StatusNoContent)
}
