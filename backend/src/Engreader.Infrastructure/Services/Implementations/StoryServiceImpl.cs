using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Stories;
using Engreader.Domain.Entities;
using Engreader.Domain.Enums;
using Engreader.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Engreader.Infrastructure.Services.Implementations;

/// <summary>
/// Full story service implementation
/// </summary>
public class StoryServiceImpl : IStoryService
{
    private readonly EngreaderDbContext _context;
    private readonly IStoryGenerationService _storyGeneration;
    private readonly ICacheService _cache;

    public StoryServiceImpl(
        EngreaderDbContext context,
        IStoryGenerationService storyGeneration,
        ICacheService cache)
    {
        _context = context;
        _storyGeneration = storyGeneration;
        _cache = cache;
    }

    public async Task<StoryResponse> GenerateStoryAsync(Guid userId, GenerateStoryRequest request, CancellationToken cancellationToken = default)
    {
        // Parse CEFR level from string (e.g., "A1" -> CefrLevel.A1)
        if (!Enum.TryParse<CefrLevel>(request.Level, true, out var level))
        {
            throw new ArgumentException($"Invalid CEFR level: {request.Level}");
        }

        // Create story record
        var story = new Story
        {
            UserId = userId,
            Topic = request.Topic,
            Level = level,
            Status = StoryStatus.Generating,
            TargetWords = request.TargetWords,
            TargetWordCount = request.TargetWords.Count
        };

        _context.Stories.Add(story);
        await _context.SaveChangesAsync(cancellationToken);

        try
        {
            // Generate story content using OpenAI
            var content = await _storyGeneration.GenerateStoryContentAsync(
                level,
                request.Topic,
                request.TargetWords,
                request.WordCount ?? 300,
                cancellationToken);

            // Validate target word usage
            var (wordsUsed, percentage) = await _storyGeneration.ValidateTargetWordsUsageAsync(content, request.TargetWords);

            // Update story
            story.Content = content;
            story.Title = ExtractTitle(content);
            story.Status = StoryStatus.Generated;
            story.ActualTargetWordUsage = wordsUsed;
            story.TargetWordPercentage = percentage;
            story.WordCount = CountWords(content);
            story.ReadingTimeMinutes = CalculateReadingTime(story.WordCount);

            await _context.SaveChangesAsync(cancellationToken);

            return MapToResponse(story);
        }
        catch (Exception)
        {
            story.Status = StoryStatus.Failed;
            await _context.SaveChangesAsync(cancellationToken);
            throw;
        }
    }

    public async Task<StoryResponse> GetStoryByIdAsync(Guid storyId, CancellationToken cancellationToken = default)
    {
        var story = await _context.Stories
            .FirstOrDefaultAsync(s => s.Id == storyId, cancellationToken);

        if (story == null)
            throw new KeyNotFoundException($"Story {storyId} not found");

        return MapToResponse(story);
    }

    public async Task<List<StoryListItem>> GetUserStoriesAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var stories = await _context.Stories
            .Where(s => s.UserId == userId)
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync(cancellationToken);

        return stories.Select(s => new StoryListItem(
            s.Id,
            s.Title,
            s.Topic,
            s.Level,
            s.Status,
            s.WordCount,
            s.ReadingTimeMinutes,
            s.CreatedAt
        )).ToList();
    }

    public async Task<StoryResponse> CompleteStoryAsync(Guid userId, CompleteStoryRequest request, CancellationToken cancellationToken = default)
    {
        var story = await _context.Stories
            .FirstOrDefaultAsync(s => s.Id == request.StoryId && s.UserId == userId, cancellationToken);

        if (story == null)
            throw new KeyNotFoundException("Story not found");

        story.CompletedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(cancellationToken);

        // Update user progress
        await UpdateUserProgressAsync(userId, cancellationToken);

        return MapToResponse(story);
    }

    public async Task<bool> DeleteStoryAsync(Guid storyId, CancellationToken cancellationToken = default)
    {
        var story = await _context.Stories.FindAsync(new object[] { storyId }, cancellationToken);
        if (story == null)
            return false;

        story.IsDeleted = true;
        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }

    private async Task UpdateUserProgressAsync(Guid userId, CancellationToken cancellationToken)
    {
        var progress = await _context.UserProgress
            .FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

        if (progress != null)
        {
            progress.TotalStoriesRead++;
            progress.LastReadingDate = DateTime.UtcNow;
            await _context.SaveChangesAsync(cancellationToken);
        }
    }

    private StoryResponse MapToResponse(Story story)
    {
        return new StoryResponse(
            story.Id,
            story.Title,
            story.Content,
            story.Topic,
            story.Level,
            story.Status,
            story.TargetWords,
            story.TargetWordCount,
            story.ActualTargetWordUsage,
            story.TargetWordPercentage,
            story.WordCount,
            story.ReadingTimeMinutes,
            story.CreatedAt,
            story.CompletedAt
        );
    }

    private string ExtractTitle(string content)
    {
        // Extract first sentence or first 50 characters as title
        var firstLine = content.Split('\n').FirstOrDefault()?.Trim() ?? "";
        return firstLine.Length > 50 ? firstLine.Substring(0, 50) + "..." : firstLine;
    }

    private int CountWords(string text)
    {
        return text.Split(new[] { ' ', '\n', '\r', '\t' }, StringSplitOptions.RemoveEmptyEntries).Length;
    }

    private int CalculateReadingTime(int wordCount)
    {
        // Average reading speed: 200 words per minute
        return (int)Math.Ceiling(wordCount / 200.0);
    }
}
