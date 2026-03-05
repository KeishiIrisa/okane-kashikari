package middleware

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

const DeviceIDKey = "deviceID"

func RequireDeviceID() gin.HandlerFunc {
	return func(c *gin.Context) {
		raw := c.GetHeader("X-Device-Id")
		if raw == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "X-Device-Id required"})
			return
		}
		id, err := uuid.Parse(raw)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "invalid X-Device-Id format"})
			return
		}
		c.Set(DeviceIDKey, id)
		c.Next()
	}
}

func GetDeviceID(c *gin.Context) uuid.UUID {
	return c.MustGet(DeviceIDKey).(uuid.UUID)
}
