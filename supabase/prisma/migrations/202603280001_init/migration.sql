CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE "GameModeCode" AS ENUM ('FRIENDS', 'COUPLES');
CREATE TYPE "LevelCode" AS ENUM ('CIELO', 'TIERRA', 'INFIERNO', 'INFRAMUNDO');
CREATE TYPE "SessionStatus" AS ENUM ('ACTIVE', 'FINISHED', 'ABANDONED');
CREATE TYPE "TurnContentType" AS ENUM ('QUESTION', 'CHALLENGE');
CREATE TYPE "TurnOutcome" AS ENUM ('COMPLETED', 'FAILED', 'SKIPPED');
CREATE TYPE "MatchWinnerKind" AS ENUM ('PLAYER', 'PAIR');
CREATE TYPE "PenaltyKind" AS ENUM ('PROPHECY', 'GROUP');
CREATE TYPE "SubmissionType" AS ENUM ('QUESTION', 'CHALLENGE');
CREATE TYPE "SubmissionStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
CREATE TYPE "ReviewDecision" AS ENUM ('APPROVE', 'REJECT');
CREATE TYPE "Platform" AS ENUM ('APP_STORE', 'PLAY_STORE', 'MANUAL');
CREATE TYPE "ProductType" AS ENUM ('ONE_TIME', 'MONTHLY');
CREATE TYPE "PremiumAccessStatus" AS ENUM ('ACTIVE', 'EXPIRED', 'CANCELED', 'TRIAL');

CREATE TABLE "Profile" (
  "id" UUID NOT NULL,
  "username" VARCHAR(40),
  "displayName" VARCHAR(100),
  "email" TEXT,
  "avatarUrl" TEXT,
  "countryCode" VARCHAR(8),
  "isGuest" BOOLEAN NOT NULL DEFAULT TRUE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Profile_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "UserPreference" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "userId" UUID NOT NULL,
  "soundEnabled" BOOLEAN NOT NULL DEFAULT TRUE,
  "tutorialCompleted" BOOLEAN NOT NULL DEFAULT FALSE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "UserPreference_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "GameMode" (
  "id" SERIAL NOT NULL,
  "code" "GameModeCode" NOT NULL,
  "label" VARCHAR(40) NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "GameMode_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Level" (
  "id" SERIAL NOT NULL,
  "code" "LevelCode" NOT NULL,
  "label" VARCHAR(40) NOT NULL,
  "isPremium" BOOLEAN NOT NULL DEFAULT FALSE,
  "intensity" INTEGER NOT NULL DEFAULT 0,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Level_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "LevelUnlockRule" (
  "id" SERIAL NOT NULL,
  "levelId" INTEGER NOT NULL,
  "requiredCompletedRounds" INTEGER NOT NULL DEFAULT 0,
  "requiresPremium" BOOLEAN NOT NULL DEFAULT TRUE,
  "eliminateOnFailure" BOOLEAN NOT NULL DEFAULT FALSE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "LevelUnlockRule_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ChallengeCategory" (
  "id" SERIAL NOT NULL,
  "slug" VARCHAR(64) NOT NULL,
  "name" VARCHAR(64) NOT NULL,
  "description" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "ChallengeCategory_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Question" (
  "id" BIGSERIAL NOT NULL,
  "modeId" INTEGER NOT NULL,
  "levelId" INTEGER,
  "categoryId" INTEGER,
  "text" TEXT NOT NULL,
  "isOfficial" BOOLEAN NOT NULL DEFAULT TRUE,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "createdByUserId" UUID,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Question_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Challenge" (
  "id" BIGSERIAL NOT NULL,
  "modeId" INTEGER NOT NULL,
  "levelId" INTEGER,
  "categoryId" INTEGER,
  "text" TEXT NOT NULL,
  "isOfficial" BOOLEAN NOT NULL DEFAULT TRUE,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "createdByUserId" UUID,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Challenge_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "GameSession" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "ownerUserId" UUID,
  "modeId" INTEGER NOT NULL,
  "selectedLevelId" INTEGER,
  "status" "SessionStatus" NOT NULL DEFAULT 'ACTIVE',
  "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "endedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "GameSession_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "SessionPlayer" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "sessionId" UUID NOT NULL,
  "displayName" VARCHAR(80) NOT NULL,
  "seatOrder" INTEGER NOT NULL,
  "pairIndex" INTEGER,
  "isEliminated" BOOLEAN NOT NULL DEFAULT FALSE,
  "eliminatedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SessionPlayer_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "SessionRound" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "sessionId" UUID NOT NULL,
  "roundNumber" INTEGER NOT NULL,
  "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "endedAt" TIMESTAMP(3),
  CONSTRAINT "SessionRound_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "SessionTurn" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "sessionId" UUID NOT NULL,
  "roundId" UUID NOT NULL,
  "playerId" UUID NOT NULL,
  "contentType" "TurnContentType" NOT NULL,
  "questionId" BIGINT,
  "challengeId" BIGINT,
  "outcome" "TurnOutcome",
  "pointsDelta" INTEGER NOT NULL DEFAULT 0,
  "validatedByGroup" BOOLEAN,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SessionTurn_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "SessionScore" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "sessionId" UUID NOT NULL,
  "playerId" UUID NOT NULL,
  "score" INTEGER NOT NULL DEFAULT 0,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SessionScore_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "FinalJudgment" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "sessionId" UUID NOT NULL,
  "winnerKind" "MatchWinnerKind" NOT NULL,
  "winnerPlayerId" UUID,
  "winnerPairIndex" INTEGER,
  "loserPlayerId" UUID,
  "loserPairIndex" INTEGER,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "FinalJudgment_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "FinalPenalty" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "judgmentId" UUID NOT NULL,
  "kind" "PenaltyKind" NOT NULL,
  "penaltyText" TEXT NOT NULL,
  "sourceQuestionId" BIGINT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "FinalPenalty_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "UserStats" (
  "userId" UUID NOT NULL,
  "matchesPlayed" INTEGER NOT NULL DEFAULT 0,
  "accumulatedScore" INTEGER NOT NULL DEFAULT 0,
  "wins" INTEGER NOT NULL DEFAULT 0,
  "losses" INTEGER NOT NULL DEFAULT 0,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "UserStats_pkey" PRIMARY KEY ("userId")
);

CREATE TABLE "GameHistorySummary" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "userId" UUID NOT NULL,
  "sessionId" UUID NOT NULL,
  "resultLabel" VARCHAR(40) NOT NULL,
  "scoreDelta" INTEGER NOT NULL DEFAULT 0,
  "playedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "GameHistorySummary_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "UserSubmission" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "userId" UUID NOT NULL,
  "type" "SubmissionType" NOT NULL,
  "modeId" INTEGER,
  "levelId" INTEGER,
  "categoryId" INTEGER,
  "sourceQuestionId" BIGINT,
  "sourceChallengeId" BIGINT,
  "contentText" TEXT NOT NULL,
  "status" "SubmissionStatus" NOT NULL DEFAULT 'PENDING',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "UserSubmission_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "SubmissionReview" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "submissionId" UUID NOT NULL,
  "reviewerUserId" UUID,
  "decision" "ReviewDecision" NOT NULL,
  "reason" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SubmissionReview_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "PremiumProduct" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "storeProductId" TEXT NOT NULL,
  "platform" "Platform" NOT NULL,
  "type" "ProductType" NOT NULL,
  "title" TEXT NOT NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "PremiumProduct_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "PremiumAccess" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "userId" UUID NOT NULL,
  "productId" UUID,
  "platform" "Platform" NOT NULL,
  "status" "PremiumAccessStatus" NOT NULL,
  "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "expiresAt" TIMESTAMP(3),
  "originalTransactionId" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "PremiumAccess_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Profile_username_key" ON "Profile"("username");
CREATE UNIQUE INDEX "Profile_email_key" ON "Profile"("email");
CREATE UNIQUE INDEX "UserPreference_userId_key" ON "UserPreference"("userId");
CREATE UNIQUE INDEX "GameMode_code_key" ON "GameMode"("code");
CREATE UNIQUE INDEX "Level_code_key" ON "Level"("code");
CREATE UNIQUE INDEX "ChallengeCategory_slug_key" ON "ChallengeCategory"("slug");
CREATE UNIQUE INDEX "SessionPlayer_sessionId_seatOrder_key" ON "SessionPlayer"("sessionId", "seatOrder");
CREATE UNIQUE INDEX "SessionRound_sessionId_roundNumber_key" ON "SessionRound"("sessionId", "roundNumber");
CREATE UNIQUE INDEX "SessionScore_sessionId_playerId_key" ON "SessionScore"("sessionId", "playerId");
CREATE UNIQUE INDEX "FinalJudgment_sessionId_key" ON "FinalJudgment"("sessionId");
CREATE UNIQUE INDEX "FinalPenalty_judgmentId_key" ON "FinalPenalty"("judgmentId");
CREATE UNIQUE INDEX "GameHistorySummary_userId_sessionId_key" ON "GameHistorySummary"("userId", "sessionId");
CREATE UNIQUE INDEX "PremiumProduct_storeProductId_key" ON "PremiumProduct"("storeProductId");

CREATE INDEX "SessionTurn_sessionId_roundId_idx" ON "SessionTurn"("sessionId", "roundId");
CREATE INDEX "UserSubmission_status_createdAt_idx" ON "UserSubmission"("status", "createdAt");
CREATE INDEX "PremiumAccess_userId_status_idx" ON "PremiumAccess"("userId", "status");

ALTER TABLE "UserPreference"
  ADD CONSTRAINT "UserPreference_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "Profile"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "LevelUnlockRule"
  ADD CONSTRAINT "LevelUnlockRule_levelId_fkey"
  FOREIGN KEY ("levelId") REFERENCES "Level"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Question"
  ADD CONSTRAINT "Question_modeId_fkey"
  FOREIGN KEY ("modeId") REFERENCES "GameMode"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Question"
  ADD CONSTRAINT "Question_levelId_fkey"
  FOREIGN KEY ("levelId") REFERENCES "Level"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Question"
  ADD CONSTRAINT "Question_categoryId_fkey"
  FOREIGN KEY ("categoryId") REFERENCES "ChallengeCategory"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Question"
  ADD CONSTRAINT "Question_createdByUserId_fkey"
  FOREIGN KEY ("createdByUserId") REFERENCES "Profile"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "Challenge"
  ADD CONSTRAINT "Challenge_modeId_fkey"
  FOREIGN KEY ("modeId") REFERENCES "GameMode"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Challenge"
  ADD CONSTRAINT "Challenge_levelId_fkey"
  FOREIGN KEY ("levelId") REFERENCES "Level"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Challenge"
  ADD CONSTRAINT "Challenge_categoryId_fkey"
  FOREIGN KEY ("categoryId") REFERENCES "ChallengeCategory"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Challenge"
  ADD CONSTRAINT "Challenge_createdByUserId_fkey"
  FOREIGN KEY ("createdByUserId") REFERENCES "Profile"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "GameSession"
  ADD CONSTRAINT "GameSession_ownerUserId_fkey"
  FOREIGN KEY ("ownerUserId") REFERENCES "Profile"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "GameSession"
  ADD CONSTRAINT "GameSession_modeId_fkey"
  FOREIGN KEY ("modeId") REFERENCES "GameMode"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "GameSession"
  ADD CONSTRAINT "GameSession_selectedLevelId_fkey"
  FOREIGN KEY ("selectedLevelId") REFERENCES "Level"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "SessionPlayer"
  ADD CONSTRAINT "SessionPlayer_sessionId_fkey"
  FOREIGN KEY ("sessionId") REFERENCES "GameSession"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "SessionRound"
  ADD CONSTRAINT "SessionRound_sessionId_fkey"
  FOREIGN KEY ("sessionId") REFERENCES "GameSession"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "SessionTurn"
  ADD CONSTRAINT "SessionTurn_sessionId_fkey"
  FOREIGN KEY ("sessionId") REFERENCES "GameSession"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SessionTurn"
  ADD CONSTRAINT "SessionTurn_roundId_fkey"
  FOREIGN KEY ("roundId") REFERENCES "SessionRound"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SessionTurn"
  ADD CONSTRAINT "SessionTurn_playerId_fkey"
  FOREIGN KEY ("playerId") REFERENCES "SessionPlayer"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SessionTurn"
  ADD CONSTRAINT "SessionTurn_questionId_fkey"
  FOREIGN KEY ("questionId") REFERENCES "Question"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "SessionTurn"
  ADD CONSTRAINT "SessionTurn_challengeId_fkey"
  FOREIGN KEY ("challengeId") REFERENCES "Challenge"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "SessionScore"
  ADD CONSTRAINT "SessionScore_sessionId_fkey"
  FOREIGN KEY ("sessionId") REFERENCES "GameSession"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SessionScore"
  ADD CONSTRAINT "SessionScore_playerId_fkey"
  FOREIGN KEY ("playerId") REFERENCES "SessionPlayer"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "FinalJudgment"
  ADD CONSTRAINT "FinalJudgment_sessionId_fkey"
  FOREIGN KEY ("sessionId") REFERENCES "GameSession"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FinalJudgment"
  ADD CONSTRAINT "FinalJudgment_winnerPlayerId_fkey"
  FOREIGN KEY ("winnerPlayerId") REFERENCES "SessionPlayer"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "FinalJudgment"
  ADD CONSTRAINT "FinalJudgment_loserPlayerId_fkey"
  FOREIGN KEY ("loserPlayerId") REFERENCES "SessionPlayer"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "FinalPenalty"
  ADD CONSTRAINT "FinalPenalty_judgmentId_fkey"
  FOREIGN KEY ("judgmentId") REFERENCES "FinalJudgment"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FinalPenalty"
  ADD CONSTRAINT "FinalPenalty_sourceQuestionId_fkey"
  FOREIGN KEY ("sourceQuestionId") REFERENCES "Question"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "UserStats"
  ADD CONSTRAINT "UserStats_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "Profile"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "GameHistorySummary"
  ADD CONSTRAINT "GameHistorySummary_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "Profile"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "GameHistorySummary"
  ADD CONSTRAINT "GameHistorySummary_sessionId_fkey"
  FOREIGN KEY ("sessionId") REFERENCES "GameSession"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "UserSubmission"
  ADD CONSTRAINT "UserSubmission_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "Profile"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "UserSubmission"
  ADD CONSTRAINT "UserSubmission_modeId_fkey"
  FOREIGN KEY ("modeId") REFERENCES "GameMode"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "UserSubmission"
  ADD CONSTRAINT "UserSubmission_levelId_fkey"
  FOREIGN KEY ("levelId") REFERENCES "Level"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "UserSubmission"
  ADD CONSTRAINT "UserSubmission_categoryId_fkey"
  FOREIGN KEY ("categoryId") REFERENCES "ChallengeCategory"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "UserSubmission"
  ADD CONSTRAINT "UserSubmission_sourceQuestionId_fkey"
  FOREIGN KEY ("sourceQuestionId") REFERENCES "Question"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "UserSubmission"
  ADD CONSTRAINT "UserSubmission_sourceChallengeId_fkey"
  FOREIGN KEY ("sourceChallengeId") REFERENCES "Challenge"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "SubmissionReview"
  ADD CONSTRAINT "SubmissionReview_submissionId_fkey"
  FOREIGN KEY ("submissionId") REFERENCES "UserSubmission"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SubmissionReview"
  ADD CONSTRAINT "SubmissionReview_reviewerUserId_fkey"
  FOREIGN KEY ("reviewerUserId") REFERENCES "Profile"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "PremiumAccess"
  ADD CONSTRAINT "PremiumAccess_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "Profile"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "PremiumAccess"
  ADD CONSTRAINT "PremiumAccess_productId_fkey"
  FOREIGN KEY ("productId") REFERENCES "PremiumProduct"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
