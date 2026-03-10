package batch

import (
	"context"
	"fmt"
	"log"

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
		hasPurpose := t.Purpose != nil && *t.Purpose != ""
		data := map[string]string{
			"transaction_id": t.ID.String(),
			"direction":      t.Direction,
		}

		if t.Direction == "LENT" {
			title = "お金の請求日"
			if hasPurpose {
				body = fmt.Sprintf("%sさんへの%s %d円の請求日です。", t.ContactName, *t.Purpose, t.Amount)
			} else {
				body = fmt.Sprintf("%sさんへの%d円の請求日です。", t.ContactName, t.Amount)
			}
		} else {
			if hasPurpose {
				body = fmt.Sprintf("%sさんへの%sの支払い期限です", t.ContactName, *t.Purpose)
			} else {
				body = fmt.Sprintf("%sさんへの支払い期限です", t.ContactName)
			}
			title = "借りの期日"
		}

		fcmClient.SendEach(ctx, tokens, title, body, data)
	}
	return nil
}
