-- Auth profile policies for mobile auth bootstrap/upsert flows.

ALTER TABLE "Profile" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "UserStats" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "UserPreference" ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profile_select_own" ON "Profile";
CREATE POLICY "profile_select_own"
ON "Profile"
FOR SELECT
TO authenticated
USING ("id" = auth.uid());

DROP POLICY IF EXISTS "profile_insert_own" ON "Profile";
CREATE POLICY "profile_insert_own"
ON "Profile"
FOR INSERT
TO authenticated
WITH CHECK ("id" = auth.uid());

DROP POLICY IF EXISTS "profile_update_own" ON "Profile";
CREATE POLICY "profile_update_own"
ON "Profile"
FOR UPDATE
TO authenticated
USING ("id" = auth.uid())
WITH CHECK ("id" = auth.uid());

DROP POLICY IF EXISTS "user_stats_select_own" ON "UserStats";
CREATE POLICY "user_stats_select_own"
ON "UserStats"
FOR SELECT
TO authenticated
USING ("userId" = auth.uid());

DROP POLICY IF EXISTS "user_stats_insert_own" ON "UserStats";
CREATE POLICY "user_stats_insert_own"
ON "UserStats"
FOR INSERT
TO authenticated
WITH CHECK ("userId" = auth.uid());

DROP POLICY IF EXISTS "user_stats_update_own" ON "UserStats";
CREATE POLICY "user_stats_update_own"
ON "UserStats"
FOR UPDATE
TO authenticated
USING ("userId" = auth.uid())
WITH CHECK ("userId" = auth.uid());

DROP POLICY IF EXISTS "user_preference_select_own" ON "UserPreference";
CREATE POLICY "user_preference_select_own"
ON "UserPreference"
FOR SELECT
TO authenticated
USING ("userId" = auth.uid());

DROP POLICY IF EXISTS "user_preference_insert_own" ON "UserPreference";
CREATE POLICY "user_preference_insert_own"
ON "UserPreference"
FOR INSERT
TO authenticated
WITH CHECK ("userId" = auth.uid());

DROP POLICY IF EXISTS "user_preference_update_own" ON "UserPreference";
CREATE POLICY "user_preference_update_own"
ON "UserPreference"
FOR UPDATE
TO authenticated
USING ("userId" = auth.uid())
WITH CHECK ("userId" = auth.uid());
