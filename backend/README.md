# okane-kashikari Backend

Go (Gin) API サーバー。端末ID (`X-Device-Id`) ベースで認可し、貸し借りデータの CRUD と集計、FCM トークン登録を提供します。

## 構成

- `cmd/api` - API サーバーエントリポイント
- `cmd/batch` - 期日チェック・FCM 通知バッチ
- `internal/` - ルーター、ミドルウェア、ハンドラ、サービス、リポジトリ、設定、FCM クライアント

## 環境変数

- `PORT` - サーバーポート (default: 8080)
- `DATABASE_URL` - PostgreSQL 接続文字列 (Supabase)
- `FCM_CREDENTIALS_JSON` - FCM サービスアカウント JSON (バッチ用)

## 実行

```bash
# API
go run ./cmd/api

# バッチ (期日通知)
go run ./cmd/batch
```
