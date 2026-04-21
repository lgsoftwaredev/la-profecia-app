-- Hito 3 support: push token persistence + moderation/premium read/write policies.

CREATE TABLE IF NOT EXISTS "PushDeviceToken" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "installationId" TEXT NOT NULL,
  "userId" UUID,
  "platform" TEXT NOT NULL,
  "fcmToken" TEXT NOT NULL,
  "notificationsEnabled" BOOLEAN NOT NULL DEFAULT FALSE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "PushDeviceToken_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "PushDeviceToken_installationId_key"
ON "PushDeviceToken" ("installationId");

CREATE INDEX IF NOT EXISTS "PushDeviceToken_userId_idx"
ON "PushDeviceToken" ("userId");

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'PushDeviceToken_userId_fkey'
  ) THEN
    ALTER TABLE "PushDeviceToken"
      ADD CONSTRAINT "PushDeviceToken_userId_fkey"
      FOREIGN KEY ("userId") REFERENCES "Profile"("id")
      ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END $$;

ALTER TABLE "PushDeviceToken" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "UserSubmission" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "PremiumAccess" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "PremiumProduct" ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "push_device_token_select_own" ON "PushDeviceToken";
CREATE POLICY "push_device_token_select_own"
ON "PushDeviceToken"
FOR SELECT
TO authenticated
USING ("userId" = auth.uid());

DROP POLICY IF EXISTS "push_device_token_upsert_own" ON "PushDeviceToken";
CREATE POLICY "push_device_token_upsert_own"
ON "PushDeviceToken"
FOR INSERT
TO authenticated
WITH CHECK ("userId" = auth.uid());

DROP POLICY IF EXISTS "push_device_token_update_own" ON "PushDeviceToken";
CREATE POLICY "push_device_token_update_own"
ON "PushDeviceToken"
FOR UPDATE
TO authenticated
USING ("userId" = auth.uid())
WITH CHECK ("userId" = auth.uid());

DROP POLICY IF EXISTS "user_submission_insert_own" ON "UserSubmission";
CREATE POLICY "user_submission_insert_own"
ON "UserSubmission"
FOR INSERT
TO authenticated
WITH CHECK (
  "userId" = auth.uid()
  AND "status" = 'PENDING'::"SubmissionStatus"
);

DROP POLICY IF EXISTS "user_submission_select_own" ON "UserSubmission";
CREATE POLICY "user_submission_select_own"
ON "UserSubmission"
FOR SELECT
TO authenticated
USING ("userId" = auth.uid());

DROP POLICY IF EXISTS "premium_access_select_own" ON "PremiumAccess";
CREATE POLICY "premium_access_select_own"
ON "PremiumAccess"
FOR SELECT
TO authenticated
USING ("userId" = auth.uid());

DROP POLICY IF EXISTS "premium_product_select_active" ON "PremiumProduct";
CREATE POLICY "premium_product_select_active"
ON "PremiumProduct"
FOR SELECT
TO anon, authenticated
USING ("isActive" = TRUE);
