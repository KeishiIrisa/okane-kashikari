-- Make transactions.purpose nullable
--
-- Safe / idempotent migration:
-- If the column is already nullable, this does nothing.

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_attribute a
    JOIN pg_class c ON c.oid = a.attrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname = 'transactions'
      AND a.attname = 'purpose'
      AND a.attnotnull = true
  ) THEN
    ALTER TABLE public.transactions
      ALTER COLUMN purpose DROP NOT NULL;
  END IF;
END $$;
