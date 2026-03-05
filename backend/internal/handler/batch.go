package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/okane-kashikari/backend/internal/batch"
	"github.com/okane-kashikari/backend/internal/config"
)

// Batch は Cloud Scheduler 等から叩くバッチ用ハンドラ
type Batch struct {
	cfg *config.Config
}

func NewBatch(cfg *config.Config) *Batch {
	return &Batch{cfg: cfg}
}

// DueDateNotifications は期日通知バッチを実行する。X-Batch-Secret が BATCH_SECRET と一致する必要がある（BATCH_SECRET 未設定時はスキップ）。
func (h *Batch) DueDateNotifications(c *gin.Context) {
	if h.cfg.BatchSecret != "" {
		if c.GetHeader("X-Batch-Secret") != h.cfg.BatchSecret {
			c.AbortWithStatus(http.StatusUnauthorized)
			return
		}
	}
	if err := batch.RunDueDateNotifications(h.cfg); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Status(http.StatusNoContent)
}
