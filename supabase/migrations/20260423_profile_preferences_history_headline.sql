-- Premium profile preferences + enriched history headline.

ALTER TABLE "UserPreference"
ADD COLUMN IF NOT EXISTS "genderIdentity" VARCHAR(16),
ADD COLUMN IF NOT EXISTS "attractionTarget" VARCHAR(16);

ALTER TABLE "GameHistorySummary"
ADD COLUMN IF NOT EXISTS "headline" VARCHAR(120);
