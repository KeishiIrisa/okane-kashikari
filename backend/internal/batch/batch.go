package batch

import (
	"context"
	"fmt"
	"log"
	"net/url"

	"github.com/okane-kashikari/backend/internal/config"
	"github.com/okane-kashikari/backend/internal/fcm"
	"github.com/okane-kashikari/backend/internal/repository"
)

// RunDueDateNotifications は「今日」が期日の未払い取引を抽出し、該当端末に FCM で通知する。
func RunDueDateNotifications(cfg *config.Config) error {
	if cfg.DatabaseURL == "" {
		log.Println("batch: DATABASE_URL not set, skip")
		return nil
	}
	ctx := context.Background()
	repo := repository.New(cfg.DatabaseURL)
	fcmClient, err := fcm.NewClient(ctx, cfg.FCMCredentialsJSON)
	if err != nil {
		return fmt.Errorf("fcm client: %w", err)
	}

	list, err := repo.ListTransactionsDueToday(ctx)
	if err != nil {
		return fmt.Errorf("list due today: %w", err)
	}
	if len(list) == 0 {
		log.Println("batch: no transactions due today")
		return nil
	}

		for _, t := range list {
		tokens, err := repo.ListTokensByDeviceID(ctx, t.OwnerID)
		if err != nil {
			log.Printf("batch: list tokens for device %s: %v", t.OwnerID, err)
			continue
		}
		if len(tokens) == 0 {
			continue
		}
		var title, body string
		data := map[string]string{
			"transaction_id": t.ID.String(),
			"direction":      t.Direction,
		}

		if t.Direction == "LENT" {
			// 通知タイトル: 「◯◯さんへの◯◯の催促時間です」
			lineMessage := fmt.Sprintf("%sさんへの%sの催促時間です", t.ContactName, t.Purpose)
			title = lineMessage

			// LINE URL スキーム。通知タップ時にアプリ側でこの URL を開く想定。
			lineURL := fmt.Sprintf("https://line.me/R/msg/text/?%s", url.QueryEscape(lineMessage))
			body = lineURL
			data["line_url"] = lineURL
		} else {
			body = fmt.Sprintf("%sさんへの%sの支払い期限です", t.ContactName, t.Purpose)
			title = "借りの期日"
		}

		fcmClient.SendEach(ctx, tokens, title, body, data)
	}
	return nil
}
