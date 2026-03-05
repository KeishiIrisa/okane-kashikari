package fcm

import (
	"context"
	"log"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

// Client FCM 送信用
type Client struct {
	client *messaging.Client
}

// NewClient は credentialsJSON が空でなければ FCM クライアントを返す。空なら nil を返す。
func NewClient(ctx context.Context, credentialsJSON string) (*Client, error) {
	if credentialsJSON == "" {
		return nil, nil
	}
	conf := &firebase.Config{ProjectID: ""}
	app, err := firebase.NewApp(ctx, conf, option.WithCredentialsJSON([]byte(credentialsJSON)))
	if err != nil {
		return nil, err
	}
	mc, err := app.Messaging(ctx)
	if err != nil {
		return nil, err
	}
	return &Client{client: mc}, nil
}

// Send は 1 トークンに通知を送る。data に transaction_id, direction などを入れる。
func (c *Client) Send(ctx context.Context, token, title, body string, data map[string]string) error {
	if c == nil || c.client == nil {
		return nil
	}
	msg := &messaging.Message{
		Notification: &messaging.Notification{Title: title, Body: body},
		Data:         data,
		Token:        token,
	}
	_, err := c.client.Send(ctx, msg)
	return err
}

// SendEach は複数トークンに同じ内容を送る。失敗したトークンはログのみ。
func (c *Client) SendEach(ctx context.Context, tokens []string, title, body string, data map[string]string) {
	if c == nil || c.client == nil || len(tokens) == 0 {
		return
	}
	for _, token := range tokens {
		if err := c.Send(ctx, token, title, body, data); err != nil {
			log.Printf("fcm send failed for token %s...: %v", token[:min(20, len(token))], err)
		}
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
