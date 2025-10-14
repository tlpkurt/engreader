using Engreader.Domain.Enums;

namespace Engreader.Application.Services.Interfaces;

/// <summary>
/// Quiz generation using OpenAI
/// </summary>
public interface IQuizGenerationService
{
    /// <summary>
    /// Generate 5 multiple-choice questions based on story content
    /// </summary>
    Task<List<QuizQuestionData>> GenerateQuestionsAsync(
        string storyContent,
        string storyTitle,
        CefrLevel level,
        CancellationToken cancellationToken = default);
}

/// <summary>
/// Quiz question data for generation
/// </summary>
public record QuizQuestionData(
    int QuestionNumber,
    string QuestionText,
    string OptionA,
    string OptionB,
    string OptionC,
    string OptionD,
    string CorrectAnswer,
    string? Explanation = null
);
