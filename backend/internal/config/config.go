package config

import "os"

type Config struct {
	Port               string
	DatabaseURL        string
	FCMCredentialsJSON string
	BatchSecret        string // Cloud Scheduler 等がバッチ起動時に送るシークレット（空ならチェックしない）
}

func Load() (*Config, error) {
	return &Config{
		Port:               getEnv("PORT", "8080"),
		DatabaseURL:        os.Getenv("DATABASE_URL"),
		FCMCredentialsJSON: os.Getenv("FCM_CREDENTIALS_JSON"),
		BatchSecret:        os.Getenv("BATCH_SECRET"),
	}, nil
}

func getEnv(key, defaultVal string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultVal
}
