-- Prompt metadata + per-player preference support.
-- Keeps templates in text while enabling structured rendering metadata.

ALTER TABLE "Profile"
ADD COLUMN IF NOT EXISTS "defaultPreferenceName" VARCHAR(80);

ALTER TABLE "Question"
ADD COLUMN IF NOT EXISTS "variables" JSONB NOT NULL DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS "timerSeconds" INTEGER,
ADD COLUMN IF NOT EXISTS "hasMatchEffect" BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE "Challenge"
ADD COLUMN IF NOT EXISTS "variables" JSONB NOT NULL DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS "timerSeconds" INTEGER,
ADD COLUMN IF NOT EXISTS "hasMatchEffect" BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE "SessionPlayer"
ADD COLUMN IF NOT EXISTS "preferenceName" VARCHAR(80),
ADD COLUMN IF NOT EXISTS "preferenceSeatOrder" INTEGER;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'Question_timerSeconds_positive_check'
  ) THEN
    ALTER TABLE "Question"
      ADD CONSTRAINT "Question_timerSeconds_positive_check"
      CHECK ("timerSeconds" IS NULL OR "timerSeconds" > 0);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'Challenge_timerSeconds_positive_check'
  ) THEN
    ALTER TABLE "Challenge"
      ADD CONSTRAINT "Challenge_timerSeconds_positive_check"
      CHECK ("timerSeconds" IS NULL OR "timerSeconds" > 0);
  END IF;
END $$;
