package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/okane-kashikari/backend/internal/middleware"
	"github.com/okane-kashikari/backend/internal/repository"
)

type Summary struct {
	repo *repository.Repository
}

func NewSummary(repo *repository.Repository) *Summary {
	return &Summary{repo: repo}
}

func (h *Summary) Get(c *gin.Context) {
	deviceID := middleware.GetDeviceID(c)
	sum, err := h.repo.GetSummary(c.Request.Context(), deviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get summary"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"total_lent_unpaid":     sum.TotalLentUnpaid,
		"total_borrowed_unpaid": sum.TotalBorrowedUnpaid,
		"recent_transactions":   sum.Recent,
	})
}
