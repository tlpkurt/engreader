using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Quizzes;

namespace Engreader.Application.Services;

/// <summary>
/// Quiz service implementation
/// </summary>
public class QuizService : IQuizService
{
    private readonly IQuizGenerationService _quizGeneration;

    public QuizService(IQuizGenerationService quizGeneration)
    {
        _quizGeneration = quizGeneration;
    }

    public async Task<QuizResponse> GenerateQuizForStoryAsync(Guid storyId, CancellationToken cancellationToken = default)
    {
        // TODO: Implement with repository and OpenAI integration
        throw new NotImplementedException("Will be implemented in Infrastructure layer");
    }

    public async Task<QuizResponse> GetQuizByIdAsync(Guid quizId, CancellationToken cancellationToken = default)
    {
        // TODO: Implement with repository
        throw new NotImplementedException("Will be implemented in Infrastructure layer");
    }

    public async Task<QuizResultResponse> SubmitQuizAsync(Guid userId, SubmitQuizRequest request, CancellationToken cancellationToken = default)
    {
        // TODO: Implement quiz evaluation and scoring
        throw new NotImplementedException("Will be implemented in Infrastructure layer");
    }

    public async Task<List<QuizResultResponse>> GetUserQuizHistoryAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        // TODO: Implement with repository
        throw new NotImplementedException("Will be implemented in Infrastructure layer");
    }
}
