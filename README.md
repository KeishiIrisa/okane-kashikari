# okane-kashikari

お金の貸し借りを管理するアプリ（端末IDベース・ログインなし）。

## 技術スタック

- **Frontend:** Flutter (iOS / Android) - Riverpod, go_router, Dio
- **Backend:** Go (Gin) - REST API
- **Database:** PostgreSQL (Supabase)
- **Infra:** GCP (Cloud Run, Cloud Scheduler), FCM

## リポジトリ構成

- `frontend/` - Flutter アプリ
- `backend/` - Go API とバッチ
- `infra/` - インフラまわり（README とメモ）

## 開発の始め方

1. **DB:** Supabase でプロジェクト作成後、`backend/supabase/migrations/` の SQL を実行
2. **Backend:** `cd backend && go run ./cmd/api`
3. **Frontend:** `cd frontend && flutter pub get && flutter run`

環境変数は `backend/.env.example` を参照。
