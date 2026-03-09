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

## マイグレーション

マイグレーションファイルは `supabase/migrations/` に番号順で管理しています。

### ファイル命名規則

```
NNN_description.sql   例: 003_add_index_to_contacts.sql
```

### 必須ルール：冪等性

GitHub Actions (`supabase-migrate.yml`) は `002_` 以降のファイルを**番号順に毎回全件実行**します。  
そのため、**新しいマイグレーションは必ず冪等（何度実行しても同じ結果になる）に書いてください**。

```sql
-- テーブル追加
CREATE TABLE IF NOT EXISTS foo (...);

-- カラム追加
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'foo' AND column_name = 'bar'
  ) THEN
    ALTER TABLE foo ADD COLUMN bar text;
  END IF;
END $$;

-- NOT NULL 解除
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_attribute a
    JOIN pg_class c ON c.oid = a.attrelid
    WHERE c.relname = 'foo' AND a.attname = 'bar' AND a.attnotnull = true
  ) THEN
    ALTER TABLE foo ALTER COLUMN bar DROP NOT NULL;
  END IF;
END $$;
```

冪等でない書き方（`CREATE TABLE foo ...` や `ALTER TABLE foo ADD COLUMN bar ...` の素の記述）は、  
2回目以降の実行でエラーになるため使用しないでください。

## 実行

```bash
# API
go run ./cmd/api

# バッチ (期日通知)
go run ./cmd/batch
```
