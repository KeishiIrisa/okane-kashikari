# infra

GCP / Supabase のデプロイ・設定用。

- **Supabase:** ダッシュボードまたは SQL エディタで `backend/supabase/migrations/001_initial_schema.sql` を実行
- **Cloud Run (API):** `backend` を Docker ビルドしてデプロイ。環境変数: `PORT`, `DATABASE_URL`, `FCM_CREDENTIALS_JSON`, `BATCH_SECRET`（任意）
- **バッチ（期日通知）:** API サーバーに `POST /internal/batch/due-date` を送ると期日通知バッチが実行される。ヘッダ `X-Batch-Secret` に `BATCH_SECRET` を設定すると認可（未設定時は誰でも実行可）
- **Cloud Scheduler:** 毎日 09:00 JST に `POST https://<your-cloud-run-url>/internal/batch/due-date` を叩くジョブを設定。認可する場合は Body なしでヘッダに `X-Batch-Secret` を付与
