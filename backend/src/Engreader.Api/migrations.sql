CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE TABLE "Users" (
        "Id" uuid NOT NULL,
        "Email" character varying(255) NOT NULL,
        "PasswordHash" text NOT NULL,
        "FirstName" character varying(100) NOT NULL,
        "LastName" character varying(100) NOT NULL,
        "NativeLanguage" text,
        "LastLoginAt" timestamp with time zone,
        "IsEmailVerified" boolean NOT NULL,
        "TenantId" uuid,
        "Role" character varying(50) NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "UpdatedAt" timestamp with time zone,
        "IsDeleted" boolean NOT NULL,
        CONSTRAINT "PK_Users" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE TABLE "Stories" (
        "Id" uuid NOT NULL,
        "UserId" uuid NOT NULL,
        "Title" character varying(200) NOT NULL,
        "Content" text NOT NULL,
        "Topic" character varying(100) NOT NULL,
        "Level" integer NOT NULL,
        "Status" integer NOT NULL,
        "TargetWords" jsonb NOT NULL,
        "TargetWordCount" integer NOT NULL,
        "ActualTargetWordUsage" integer NOT NULL,
        "TargetWordPercentage" numeric NOT NULL,
        "WordCount" integer NOT NULL,
        "ReadingTimeMinutes" integer NOT NULL,
        "CompletedAt" timestamp with time zone,
        "CreatedAt" timestamp with time zone NOT NULL,
        "UpdatedAt" timestamp with time zone,
        "IsDeleted" boolean NOT NULL,
        CONSTRAINT "PK_Stories" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_Stories_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE TABLE "UserEvents" (
        "Id" uuid NOT NULL,
        "UserId" uuid NOT NULL,
        "EventType" text NOT NULL,
        "EventData" jsonb NOT NULL,
        "EventTime" timestamp with time zone NOT NULL,
        "StoryId" uuid,
        "QuizId" uuid,
        "CreatedAt" timestamp with time zone NOT NULL,
        "UpdatedAt" timestamp with time zone,
        "IsDeleted" boolean NOT NULL,
        CONSTRAINT "PK_UserEvents" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_UserEvents_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE TABLE "UserProgress" (
        "Id" uuid NOT NULL,
        "UserId" uuid NOT NULL,
        "CurrentLevel" integer NOT NULL,
        "TotalStoriesRead" integer NOT NULL,
        "TotalQuizzesCompleted" integer NOT NULL,
        "AverageQuizScore" numeric NOT NULL,
        "TotalWordsLearned" integer NOT NULL,
        "TotalTranslationsViewed" integer NOT NULL,
        "TotalReadingTimeMinutes" integer NOT NULL,
        "StreakDays" integer NOT NULL,
        "LastReadingDate" timestamp with time zone,
        "CreatedAt" timestamp with time zone NOT NULL,
        "UpdatedAt" timestamp with time zone,
        "IsDeleted" boolean NOT NULL,
        CONSTRAINT "PK_UserProgress" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_UserProgress_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE TABLE "Quizzes" (
        "Id" uuid NOT NULL,
        "StoryId" uuid NOT NULL,
        "Title" text NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "UpdatedAt" timestamp with time zone,
        "IsDeleted" boolean NOT NULL,
        CONSTRAINT "PK_Quizzes" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_Quizzes_Stories_StoryId" FOREIGN KEY ("StoryId") REFERENCES "Stories" ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE TABLE "Translations" (
        "Id" uuid NOT NULL,
        "StoryId" uuid,
        "SourceText" text NOT NULL,
        "TargetText" text NOT NULL,
        "SourceLanguage" text NOT NULL,
        "TargetLanguage" text NOT NULL,
        "IsWord" boolean NOT NULL,
        "UsageCount" integer NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "UpdatedAt" timestamp with time zone,
        "IsDeleted" boolean NOT NULL,
        CONSTRAINT "PK_Translations" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_Translations_Stories_StoryId" FOREIGN KEY ("StoryId") REFERENCES "Stories" ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE TABLE "QuizAttempts" (
        "Id" uuid NOT NULL,
        "UserId" uuid NOT NULL,
        "QuizId" uuid NOT NULL,
        "Score" integer NOT NULL,
        "Percentage" numeric NOT NULL,
        "TimeSpentSeconds" integer NOT NULL,
        "UserAnswers" jsonb NOT NULL,
        "CompletedAt" timestamp with time zone NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "UpdatedAt" timestamp with time zone,
        "IsDeleted" boolean NOT NULL,
        CONSTRAINT "PK_QuizAttempts" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_QuizAttempts_Quizzes_QuizId" FOREIGN KEY ("QuizId") REFERENCES "Quizzes" ("Id") ON DELETE CASCADE,
        CONSTRAINT "FK_QuizAttempts_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE TABLE "QuizQuestions" (
        "Id" uuid NOT NULL,
        "QuizId" uuid NOT NULL,
        "QuestionNumber" integer NOT NULL,
        "QuestionText" text NOT NULL,
        "OptionA" text NOT NULL,
        "OptionB" text NOT NULL,
        "OptionC" text NOT NULL,
        "OptionD" text NOT NULL,
        "CorrectAnswer" character varying(1) NOT NULL,
        "Explanation" text,
        "CreatedAt" timestamp with time zone NOT NULL,
        "UpdatedAt" timestamp with time zone,
        "IsDeleted" boolean NOT NULL,
        CONSTRAINT "PK_QuizQuestions" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_QuizQuestions_Quizzes_QuizId" FOREIGN KEY ("QuizId") REFERENCES "Quizzes" ("Id") ON DELETE CASCADE
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE INDEX "IX_QuizAttempts_QuizId" ON "QuizAttempts" ("QuizId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE INDEX "IX_QuizAttempts_UserId" ON "QuizAttempts" ("UserId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE INDEX "IX_QuizQuestions_QuizId" ON "QuizQuestions" ("QuizId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE INDEX "IX_Quizzes_StoryId" ON "Quizzes" ("StoryId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE INDEX "IX_Stories_UserId" ON "Stories" ("UserId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE INDEX "IX_Translations_SourceText_TargetLanguage" ON "Translations" ("SourceText", "TargetLanguage");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE INDEX "IX_Translations_StoryId" ON "Translations" ("StoryId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE INDEX "IX_UserEvents_EventTime" ON "UserEvents" ("EventTime");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE INDEX "IX_UserEvents_UserId" ON "UserEvents" ("UserId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE INDEX "IX_UserProgress_UserId" ON "UserProgress" ("UserId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    CREATE UNIQUE INDEX "IX_Users_Email" ON "Users" ("Email");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251013100815_InitialCreate') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20251013100815_InitialCreate', '9.0.9');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251014100247_AddValueConverters') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20251014100247_AddValueConverters', '9.0.9');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251104102821_UpdateQuizAttemptAnswersToStringKeys') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20251104102821_UpdateQuizAttemptAnswersToStringKeys', '9.0.9');
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251104114559_AddStoryCompletionFields') THEN
    ALTER TABLE "Stories" ADD "IsCompleted" boolean NOT NULL DEFAULT FALSE;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251104114559_AddStoryCompletionFields') THEN
    ALTER TABLE "Stories" ADD "ReadingTimeSeconds" integer NOT NULL DEFAULT 0;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20251104114559_AddStoryCompletionFields') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20251104114559_AddStoryCompletionFields', '9.0.9');
    END IF;
END $EF$;
COMMIT;

