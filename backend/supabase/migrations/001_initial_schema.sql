-- required for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- devices: 端末単位の疑似ユーザー (device_user_id = id)
CREATE TABLE IF NOT EXISTS devices (
  id uuid PRIMARY KEY,
  default_reminder_msg text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- contacts: 取引相手
CREATE TABLE IF NOT EXISTS contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  name text NOT NULL,
  last_used_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(owner_id, name)
);

CREATE INDEX IF NOT EXISTS idx_contacts_owner_last_used ON contacts(owner_id, last_used_at DESC);

-- transactions: 貸し借りデータ
CREATE TABLE IF NOT EXISTS transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  contact_id uuid NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
  amount integer NOT NULL CHECK (amount > 0),
  purpose text NOT NULL,
  direction text NOT NULL CHECK (direction IN ('LENT', 'BORROWED')),
  due_date timestamptz,
  status text NOT NULL CHECK (status IN ('unpaid', 'paid')) DEFAULT 'unpaid',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_transactions_owner ON transactions(owner_id);
CREATE INDEX IF NOT EXISTS idx_transactions_owner_direction_status ON transactions(owner_id, direction, status);
CREATE INDEX IF NOT EXISTS idx_transactions_due_status ON transactions(due_date, status) WHERE due_date IS NOT NULL;

-- device_tokens: FCM トークン
CREATE TABLE IF NOT EXISTS device_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id uuid NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  token text NOT NULL,
  platform text NOT NULL CHECK (platform IN ('ios', 'android')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(device_id, token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_device ON device_tokens(device_id);

-- notifications: 通知履歴
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id uuid NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  device_id uuid NOT NULL REFERENCES devices(id),
  direction text NOT NULL CHECK (direction IN ('LENT', 'BORROWED')),
  sent_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_device_sent ON notifications(device_id, sent_at DESC);
