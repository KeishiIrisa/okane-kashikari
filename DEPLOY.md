# 本番環境へのデプロイ手順

Flutter モバイルアプリ（iOS / Android）、Go バックエンド（Cloud Run）、Supabase（PostgreSQL）、Firebase（FCM）を本番用にセットアップする手順です。

---

## 前提

- このリポジトリが GitHub 上にある（`main` ブランチ）
- 開発用ローカル環境で以下が一通り動作確認済み
  - `docker compose up` で `db`+`api` が起動し、`curl` や Flutter アプリから API が呼べる
  - 期日通知バッチ（`/internal/batch/due-date`）がエラーなく動作する
- アカウント
  - Google Cloud アカウント（GCP プロジェクトを作成・課金有効化済み）
  - Supabase アカウント
  - Firebase コンソール（FCM 用）
  - Google Play Console（Android リリース用）
  - App Store Connect（iOS リリース用）

---

## 全体構成（本番）

- **モバイルアプリ（Flutter）**
  - iOS / Android ネイティブアプリとしてビルド・配布
- **バックエンド API**
  - Go (Gin) コンテナを Cloud Run で公開
  - DB は Supabase PostgreSQL を利用
- **DB**
  - Supabase Project 上の PostgreSQL に `devices / contacts / transactions / device_tokens / notifications` テーブルを作成
- **通知**
  - Cloud Scheduler → Cloud Run バッチ → FCM で期日通知を送信
- **認証**
  - ログインなし、`X-Device-Id` による端末単位ユーザー

---

## 1. Supabase（本番）プロジェクトの準備

1. Supabase のダッシュボードで **新しいプロジェクト** を作成
2. プロジェクトの **DB 接続文字列** を控える  
   例: `postgres://postgres:xxxxxx@db.prod.supabase.co:5432/postgres`
3. SQL エディタを開き、以下を実行（このリポジトリの場合は `backend/supabase/migrations/001_initial_schema.sql` の内容をそのまま流せば良い）
   - `CREATE EXTENSION IF NOT EXISTS pgcrypto;`
   - `devices / contacts / transactions / device_tokens / notifications` テーブル作成
   - インデックス作成

> ローカルと同じスキーマになるようにする。基本的には `001_initial_schema.sql` をコピー＆ペーストで実行すればOK。

---

## 2. Firebase プロジェクト + FCM 設定

### 2-1. Firebase プロジェクト作成

1. [Firebase Console](https://console.firebase.google.com/) で **プロジェクトを作成**
2. この Firebase プロジェクトを、後で使う GCP プロジェクトと紐づける（通常は同じ GCP プロジェクトになる）

### 2-2. Android アプリを Firebase に登録

1. Firebase コンソール → 「アプリを追加」 → Android
2. パッケージ名に **`com.okane.kashikari.frontend`** を指定（`android/app/build.gradle.kts` の `applicationId` と一致させる）
3. `google-services.json` をダウンロードし、**`frontend/android/app/google-services.json`** に配置
4. Android 側ビルド設定
   - `frontend/android/build.gradle.kts` に以下の plugins があることを確認

     ```kotlin
     plugins {
         id("com.google.gms.google-services") version "4.4.4" apply false
     }
     ```

   - `frontend/android/app/build.gradle.kts` に以下があることを確認

     ```kotlin
     plugins {
         id("com.android.application")
         id("kotlin-android")
         id("dev.flutter.flutter-gradle-plugin")
         id("com.google.gms.google-services")
     }

     dependencies {
         implementation(platform("com.google.firebase:firebase-bom:34.10.0"))
         implementation("com.google.firebase:firebase-analytics")
     }
     ```

5. Flutter 側で `firebase_core` / `firebase_messaging` パッケージが `pubspec.yaml` に入っていることを確認

### 2-3. iOS アプリ登録（必要なら）

1. Firebase コンソール → 「アプリを追加」 → iOS
2. バンドルID（Xcode の `Runner` ターゲットの `PRODUCT_BUNDLE_IDENTIFIER`）を指定
3. `GoogleService-Info.plist` をダウンロードし、**`frontend/ios/Runner/GoogleService-Info.plist`** に配置
4. `cd frontend/ios && pod install` を実行し、Firebase SDK を導入

---

## 3. GCP プロジェクトと Cloud Run 準備

### 3-1. GCP プロジェクトの作成 / 選択

1. [Google Cloud Console](https://console.cloud.google.com/) でプロジェクトを作成（例: `okane-kashikari-prod`）
2. プロジェクト ID を控える（例: `okane-kashikari-prod`）
3. 課金（Billing）を有効化
4. 以下の API を有効化
   - Cloud Run Admin API
   - Cloud Build API
   - Cloud Scheduler API（期日バッチ用）

### 3-2. サービスアカウント（GitHub Actions / Cloud Run 用）

1. [IAM と管理] → [サービス アカウント] で新規作成（例: `github-actions-deploy`）
2. 付与するロール（最低限）
   - `roles/run.admin`（Cloud Run 管理者）
   - `roles/cloudbuild.builds.editor`（Cloud Build 編集者）
   - `roles/storage.admin`（コンテナイメージ push 用）
   - `roles/iam.serviceAccountUser`
3. サービスアカウントの「キー」→ JSON キーを作成し、ローカルにダウンロード
4. この JSON 内容を GitHub Secrets で使用する

---

## 4. GitHub Secrets の設定（バックエンド Cloud Run 用）

GitHub のリポジトリ → **Settings → Secrets and variables → Actions** で以下を登録する。

- **`GCP_PROJECT_ID`**  
  例: `okane-kashikari-prod`
- **`GCP_SA_KEY`**  
  手順 3-2 でダウンロードしたサービスアカウント JSON の **全文**
- **`DATABASE_URL`**  
  Supabase PostgreSQL の接続文字列（例: `postgres://...`）
- **`FCM_CREDENTIALS_JSON`**  
  Firebase サービスアカウント（Cloud Messaging 用）の JSON 全文  
  Firebase コンソール → プロジェクト設定 → サービスアカウント → 新しい秘密鍵 から取得
- **`BATCH_SECRET`**  
  Cloud Scheduler → `/internal/batch/due-date` を叩くときの簡易シークレット文字列（任意、空でも動くが本番では設定推奨）

---

## 5. バックエンド（Cloud Run）へのデプロイ

### 5-1. 最初のデプロイ

1. `main` ブランチに最新の `backend/` のコードを push
2. GitHub の Actions タブで、`backend-deploy.yml` に相当するワークフローを確認
3. 必要であれば「Run workflow」で手動実行
4. デプロイ完了後、[Cloud Run](https://console.cloud.google.com/run) でサービス（例: `okane-kashikari-api`）を開き、**URL** を控える  
   例: `https://okane-kashikari-api-xxxxxx-an.a.run.app`

### 5-2. Cloud Scheduler バッチの設定

1. GCP コンソール → Cloud Scheduler
2. 新しいジョブを作成
   - 頻度: `0 9 * * *`（毎日 9:00 JST）
   - タイムゾーン: `Asia/Tokyo`
   - ターゲット: HTTP
   - URL: `https://<Cloud Run の URL>/internal/batch/due-date`
   - メソッド: `POST`
   - ヘッダ（任意）: `X-Batch-Secret: <BATCH_SECRET の値>`
   - 認証: Cloud Run サービスアカウント、または「認証なし」（本番では前者を推奨）

---

## 6. Flutter アプリの本番ビルドとストア登録

### 6-1. Android (Google Play)

1. Android 用の署名鍵（keystore）を作成し、`android/app` の `key.properties` / `build.gradle.kts` に設定
2. `flutter build appbundle --release -t lib/main_prod.dart` を実行し、`build/app/outputs/bundle/release/app-release.aab` を生成
3. Google Play Console にアプリを作成
   - パッケージ名: `com.okane.kashikari.frontend`
   - 必要なスクリーンショット、アイコン、説明文などを登録
4. `app-release.aab` をアップロードし、トラック（内部テスト / クローズド / プロダクション）にリリース

### 6-2. iOS (App Store)

1. Xcode で `frontend/ios/Runner.xcworkspace` を開く
2. Bundle Identifier / チーム / Signing を設定
3. `flutter build ipa --release` または Xcode からアーカイブを作成
4. App Store Connect にアプリを登録し、アーカイブをアップロード
5. メタデータ・スクリーンショットを登録し、審査に提出

---

## 7. 本番動作確認

1. Android / iOS のテストデバイスにストア版アプリをインストール
2. 通常のフローを確認
   - アプリを起動するとダッシュボードが表示される
   - 新規取引を登録すると、Cloud Run / Supabase に反映される
   - （期日を当日にした取引を用意して）翌朝 9:00 頃に FCM 通知が届くか確認
   - 通知タップ時の挙動
     - LENT: LINE が起動し、催促メッセージが入力された画面になる
     - BORROWED: アプリの借りリスト画面に遷移する

---

## 8. チェックリスト（要約）

- **Supabase**
  - [ ] 本番プロジェクト作成
  - [ ] `001_initial_schema.sql` を適用
- **Firebase**
  - [ ] Firebase プロジェクト作成
  - [ ] Android アプリ追加（`com.okane.kashikari.frontend`）、`google-services.json` 配置
  - [ ] iOS アプリ追加（必要なら）、`GoogleService-Info.plist` 配置
- **GCP / Cloud Run**
  - [ ] プロジェクト作成・API有効化（Run / Build / Scheduler）
  - [ ] サービスアカウント作成＋ロール付与
  - [ ] GitHub Secrets に `GCP_PROJECT_ID`, `GCP_SA_KEY`, `DATABASE_URL`, `FCM_CREDENTIALS_JSON`, `BATCH_SECRET` を登録
  - [ ] Cloud Run に API をデプロイ
  - [ ] Cloud Scheduler で `/internal/batch/due-date` ジョブを作成
- **Flutter アプリ**
  - [ ] Android: keystore 設定、`flutter build appbundle`、Google Play 登録
  - [ ] iOS: Xcode で署名設定、アーカイブ、App Store Connect 登録
- **最終確認**
  - [ ] 本番アプリからの API 呼び出しが Cloud Run / Supabase に届いている
  - [ ] 期日通知が FCM 経由で正常に届き、LENT/BORROWED で期待通りの挙動になる

