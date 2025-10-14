using Engreader.Contracts.Progress;

namespace Engreader.Application.Services.Interfaces;

/// <summary>
/// User progress tracking service
/// </summary>
public interface IProgressService
{
    Task<ProgressResponse> GetUserProgressAsync(Guid userId, CancellationToken cancellationToken = default);
    Task UpdateProgressAsync(Guid userId, CancellationToken cancellationToken = default);
    Task TrackEventAsync(Guid userId, TrackEventRequest request, CancellationToken cancellationToken = default);
}
