-- RLS for FinalPenalty so authenticated owners can upsert their own final penalty
-- based on ownership of the related GameSession through FinalJudgment.

ALTER TABLE public."FinalPenalty" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "final_penalty_select_own_session"
ON public."FinalPenalty"
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public."FinalJudgment" fj
    JOIN public."GameSession" gs ON gs."id" = fj."sessionId"
    WHERE fj."id" = "FinalPenalty"."judgmentId"
      AND gs."ownerUserId" = auth.uid()
  )
);

CREATE POLICY "final_penalty_insert_own_session"
ON public."FinalPenalty"
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public."FinalJudgment" fj
    JOIN public."GameSession" gs ON gs."id" = fj."sessionId"
    WHERE fj."id" = "FinalPenalty"."judgmentId"
      AND gs."ownerUserId" = auth.uid()
  )
);

CREATE POLICY "final_penalty_update_own_session"
ON public."FinalPenalty"
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public."FinalJudgment" fj
    JOIN public."GameSession" gs ON gs."id" = fj."sessionId"
    WHERE fj."id" = "FinalPenalty"."judgmentId"
      AND gs."ownerUserId" = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public."FinalJudgment" fj
    JOIN public."GameSession" gs ON gs."id" = fj."sessionId"
    WHERE fj."id" = "FinalPenalty"."judgmentId"
      AND gs."ownerUserId" = auth.uid()
  )
);
