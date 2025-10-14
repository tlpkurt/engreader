using Engreader.Contracts.Quizzes;

namespace Engreader.Application.Services.Interfaces;

/// <summary>
/// Quiz generation and evaluation service
/// </summary>
public interface IQuizService
{
    Task<QuizResponse> GenerateQuizForStoryAsync(Guid storyId, CancellationToken cancellationToken = default);
    Task<QuizResponse> GetQuizByIdAsync(Guid quizId, CancellationToken cancellationToken = default);
    Task<QuizResultResponse> SubmitQuizAsync(Guid userId, SubmitQuizRequest request, CancellationToken cancellationToken = default);
    Task<List<QuizResultResponse>> GetUserQuizHistoryAsync(Guid userId, CancellationToken cancellationToken = default);
}
