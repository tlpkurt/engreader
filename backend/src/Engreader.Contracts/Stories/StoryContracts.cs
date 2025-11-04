using Engreader.Domain.Enums;

namespace Engreader.Contracts.Stories;

/// <summary>
/// Request to generate a new story
/// </summary>
public record GenerateStoryRequest(
    string Level,  // "A1", "A2", "B1", "B2", "C1", "C2"
    string Topic,
    List<string> TargetWords,
    int? WordCount = null
);

/// <summary>
/// Story response DTO
/// </summary>
public record StoryResponse(
    Guid Id,
    string Title,
    string Content,
    string Topic,
    CefrLevel Level,
    StoryStatus Status,
    List<string> TargetWords,
    int TargetWordCount,
    int ActualTargetWordUsage,
    decimal TargetWordPercentage,
    int WordCount,
    int ReadingTimeMinutes,
    int ReadingTimeSeconds,
    bool IsCompleted,
    DateTime CreatedAt,
    DateTime? CompletedAt,
    Quizzes.QuizResponse? Quiz = null  // Quiz included with story
);

/// <summary>
/// Story list item (summary)
/// </summary>
public record StoryListItem(
    Guid Id,
    string Title,
    string? Topic,  // Nullable - some stories may not have a topic
    CefrLevel Level,
    StoryStatus Status,
    int WordCount,
    int ReadingTimeMinutes,
    bool IsCompleted,
    DateTime CreatedAt
);

/// <summary>
/// Request to mark story as completed
/// </summary>
public record CompleteStoryRequest(
    Guid StoryId,
    int TimeSpentSeconds
);
