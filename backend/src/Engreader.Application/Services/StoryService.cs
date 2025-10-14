using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Stories;

namespace Engreader.Application.Services;

/// <summary>
/// Story service implementation
/// </summary>
public class StoryService : IStoryService
{
    private readonly IStoryGenerationService _storyGeneration;

    public StoryService(IStoryGenerationService storyGeneration)
    {
        _storyGeneration = storyGeneration;
    }

    public async Task<StoryResponse> GenerateStoryAsync(Guid userId, GenerateStoryRequest request, CancellationToken cancellationToken = default)
    {
        // TODO: Implement with repository and OpenAI integration
        throw new NotImplementedException("Will be implemented in Infrastructure layer");
    }

    public async Task<StoryResponse> GetStoryByIdAsync(Guid storyId, CancellationToken cancellationToken = default)
    {
        // TODO: Implement with repository
        throw new NotImplementedException("Will be implemented in Infrastructure layer");
    }

    public async Task<List<StoryListItem>> GetUserStoriesAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        // TODO: Implement with repository
        throw new NotImplementedException("Will be implemented in Infrastructure layer");
    }

    public async Task<StoryResponse> CompleteStoryAsync(Guid userId, CompleteStoryRequest request, CancellationToken cancellationToken = default)
    {
        // TODO: Implement with repository
        throw new NotImplementedException("Will be implemented in Infrastructure layer");
    }

    public async Task<bool> DeleteStoryAsync(Guid storyId, CancellationToken cancellationToken = default)
    {
        // TODO: Implement with repository
        throw new NotImplementedException("Will be implemented in Infrastructure layer");
    }
}
