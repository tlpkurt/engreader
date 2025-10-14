using Engreader.Domain.Enums;

namespace Engreader.Contracts.Progress;

/// <summary>
/// User progress summary
/// </summary>
public record ProgressResponse(
    Guid UserId,
    CefrLevel CurrentLevel,
    int TotalStoriesRead,
    int TotalQuizzesCompleted,
    decimal AverageQuizScore,
    int TotalWordsLearned,
    int TotalTranslationsViewed,
    int TotalReadingTimeMinutes,
    int StreakDays,
    DateTime? LastReadingDate
);

/// <summary>
/// Analytics event tracking
/// </summary>
public record TrackEventRequest(
    string EventType,
    string EventData,
    Guid? StoryId = null,
    Guid? QuizId = null
);
