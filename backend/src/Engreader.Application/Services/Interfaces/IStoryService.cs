using Engreader.Contracts.Stories;

namespace Engreader.Application.Services.Interfaces;

/// <summary>
/// Story generation and management service
/// </summary>
public interface IStoryService
{
    Task<StoryResponse> GenerateStoryAsync(Guid userId, GenerateStoryRequest request, CancellationToken cancellationToken = default);
    Task<StoryResponse> GetStoryByIdAsync(Guid storyId, CancellationToken cancellationToken = default);
    Task<List<StoryListItem>> GetUserStoriesAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<StoryResponse> CompleteStoryAsync(Guid userId, CompleteStoryRequest request, CancellationToken cancellationToken = default);
    Task<bool> DeleteStoryAsync(Guid storyId, CancellationToken cancellationToken = default);
}
