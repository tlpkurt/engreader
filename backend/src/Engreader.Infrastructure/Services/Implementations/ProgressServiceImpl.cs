using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Progress;
using Engreader.Domain.Entities;
using Engreader.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Engreader.Infrastructure.Services.Implementations;

/// <summary>
/// Full progress tracking service implementation
/// </summary>
public class ProgressServiceImpl : IProgressService
{
    private readonly EngreaderDbContext _context;

    public ProgressServiceImpl(EngreaderDbContext context)
    {
        _context = context;
    }

    public async Task<ProgressResponse> GetUserProgressAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var progress = await _context.UserProgress
            .FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

        if (progress == null)
        {
            // Create initial progress if not exists
            progress = new UserProgress
            {
                UserId = userId,
                CurrentLevel = Domain.Enums.CefrLevel.A1
            };
            _context.UserProgress.Add(progress);
            await _context.SaveChangesAsync(cancellationToken);
        }

        return new ProgressResponse(
            progress.UserId,
            progress.CurrentLevel,
            progress.TotalStoriesRead,
            progress.TotalQuizzesCompleted,
            progress.AverageQuizScore,
            progress.TotalWordsLearned,
            progress.TotalTranslationsViewed,
            progress.TotalReadingTimeMinutes,
            progress.StreakDays,
            progress.LastReadingDate
        );
    }

    public async Task UpdateProgressAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var progress = await _context.UserProgress
            .FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

        if (progress == null)
            return;

        // Calculate streak
        if (progress.LastReadingDate.HasValue)
        {
            var daysSinceLastReading = (DateTime.UtcNow.Date - progress.LastReadingDate.Value.Date).Days;
            
            if (daysSinceLastReading == 1)
            {
                // Continue streak
                progress.StreakDays++;
            }
            else if (daysSinceLastReading > 1)
            {
                // Streak broken
                progress.StreakDays = 1;
            }
            // Same day = no change
        }
        else
        {
            progress.StreakDays = 1;
        }

        progress.LastReadingDate = DateTime.UtcNow;
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task TrackEventAsync(Guid userId, TrackEventRequest request, CancellationToken cancellationToken = default)
    {
        var userEvent = new UserEvent
        {
            UserId = userId,
            EventType = request.EventType,
            EventData = request.EventData,
            EventTime = DateTime.UtcNow,
            StoryId = request.StoryId,
            QuizId = request.QuizId
        };

        _context.UserEvents.Add(userEvent);
        await _context.SaveChangesAsync(cancellationToken);

        // Update progress based on event type
        if (request.EventType == "WordTap" || request.EventType == "SentencePress")
        {
            var progress = await _context.UserProgress
                .FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

            if (progress != null)
            {
                progress.TotalTranslationsViewed++;
                await _context.SaveChangesAsync(cancellationToken);
            }
        }
    }
}
