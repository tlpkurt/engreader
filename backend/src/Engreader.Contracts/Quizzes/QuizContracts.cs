namespace Engreader.Contracts.Quizzes;

/// <summary>
/// Quiz response with questions
/// </summary>
public record QuizResponse(
    Guid Id,
    Guid StoryId,
    string Title,
    List<QuizQuestionDto> Questions
);

/// <summary>
/// Quiz question DTO
/// </summary>
public record QuizQuestionDto(
    Guid Id,
    int QuestionNumber,
    string QuestionText,
    string OptionA,
    string OptionB,
    string OptionC,
    string OptionD
);

/// <summary>
/// Submit quiz answers request
/// </summary>
public record SubmitQuizRequest(
    Guid QuizId,
    Dictionary<string, string> Answers, // QuestionNumber (as string) -> Answer (A/B/C/D)
    int TimeSpentSeconds
);

/// <summary>
/// Quiz result response
/// </summary>
public record QuizResultResponse(
    Guid AttemptId,
    int Score,
    decimal Percentage,
    int TotalQuestions,
    List<QuizAnswerResult> Results
);

/// <summary>
/// Individual answer result
/// </summary>
public record QuizAnswerResult(
    int QuestionNumber,
    string QuestionText,
    string UserAnswer,
    string CorrectAnswer,
    bool IsCorrect,
    string? Explanation
);
