-- Adds a stable profile reference for authenticated participants.
ALTER TABLE public."SessionPlayer"
ADD COLUMN IF NOT EXISTS "profileId" UUID;
