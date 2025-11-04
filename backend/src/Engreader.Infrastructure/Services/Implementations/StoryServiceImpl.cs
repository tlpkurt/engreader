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
    private readonly IQuizService _quizService;

    public StoryServiceImpl(
        EngreaderDbContext context,
        IStoryGenerationService storyGeneration,
        ICacheService cache,
        IQuizService quizService)
    {
        _context = context;
        _storyGeneration = storyGeneration;
        _cache = cache;
        _quizService = quizService;
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
            var generatedContent = await _storyGeneration.GenerateStoryContentAsync(
                level,
                request.Topic,
                request.TargetWords,
                request.WordCount ?? 300,
                cancellationToken);

            // Extract title and content
            var (title, content) = ExtractTitleAndContent(generatedContent);

            // Validate target word usage
            var (wordsUsed, percentage) = await _storyGeneration.ValidateTargetWordsUsageAsync(content, request.TargetWords);

            // Update story
            story.Content = content;
            story.Title = title;
            story.Status = StoryStatus.Generated;
            story.ActualTargetWordUsage = wordsUsed;
            story.TargetWordPercentage = percentage;
            story.WordCount = CountWords(content);
            story.ReadingTimeMinutes = CalculateReadingTime(story.WordCount);

            await _context.SaveChangesAsync(cancellationToken);

            // Generate quiz automatically after story is created
            Contracts.Quizzes.QuizResponse? quiz = null;
            try
            {
                quiz = await _quizService.GenerateQuizForStoryAsync(story.Id, cancellationToken);
            }
            catch (Exception ex)
            {
                // Log quiz generation failure but don't fail story creation
                // Quiz can be generated later on demand
                Console.WriteLine($"Failed to generate quiz for story {story.Id}: {ex.Message}");
            }

            return MapToResponse(story, quiz);
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

        // Try to get existing quiz for this story (don't generate, just retrieve)
        Contracts.Quizzes.QuizResponse? quiz = null;
        try
        {
            var existingQuiz = await _context.Quizzes
                .Include(q => q.Questions)
                .Where(q => q.StoryId == storyId && !q.IsDeleted)
                .OrderByDescending(q => q.CreatedAt)
                .FirstOrDefaultAsync(cancellationToken);

            if (existingQuiz != null)
            {
                // Map existing quiz to response
                quiz = new Contracts.Quizzes.QuizResponse(
                    existingQuiz.Id,
                    existingQuiz.StoryId,
                    existingQuiz.Title,
                    existingQuiz.Questions
                        .OrderBy(q => q.QuestionNumber)
                        .Select(q => new Contracts.Quizzes.QuizQuestionDto(
                            q.Id,
                            q.QuestionNumber,
                            q.QuestionText,
                            q.OptionA,
                            q.OptionB,
                            q.OptionC,
                            q.OptionD
                        )).ToList()
                );
            }
        }
        catch
        {
            // Quiz not available, continue without it
        }

        return MapToResponse(story, quiz);
    }

    public async Task<List<StoryListItem>> GetUserStoriesAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var stories = await _context.Stories
            .Where(s => s.UserId == userId && s.Status == StoryStatus.Generated)
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
            s.IsCompleted,
            s.CreatedAt
        )).ToList();
    }

    public async Task<StoryResponse> CompleteStoryAsync(Guid userId, CompleteStoryRequest request, CancellationToken cancellationToken = default)
    {
        var story = await _context.Stories
            .FirstOrDefaultAsync(s => s.Id == request.StoryId && s.UserId == userId, cancellationToken);

        if (story == null)
            throw new KeyNotFoundException("Story not found");

        story.IsCompleted = true;
        story.CompletedAt = DateTime.UtcNow;
        story.ReadingTimeSeconds = request.TimeSpentSeconds;
        await _context.SaveChangesAsync(cancellationToken);

        // Update user progress
        await UpdateUserProgressAsync(userId, cancellationToken);

        return MapToResponse(story, null);
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

    private StoryResponse MapToResponse(Story story, Contracts.Quizzes.QuizResponse? quiz = null)
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
            story.ReadingTimeSeconds,
            story.IsCompleted,
            story.CreatedAt,
            story.CompletedAt,
            quiz
        );
    }

    private (string title, string content) ExtractTitleAndContent(string generatedContent)
    {
        // Try to extract title from "TITLE: xxx" format
        var lines = generatedContent.Split('\n');
        
        if (lines.Length > 0 && lines[0].Trim().StartsWith("TITLE:", StringComparison.OrdinalIgnoreCase))
        {
            var title = lines[0].Substring(lines[0].IndexOf(':') + 1).Trim();
            
            // Skip the TITLE line and any empty lines after it
            var contentLines = lines.Skip(1)
                .SkipWhile(line => string.IsNullOrWhiteSpace(line))
                .ToList();
            
            var content = string.Join("\n", contentLines).Trim();
            return (title, content);
        }
        
        // Fallback: use first sentence as title
        var firstLine = lines.FirstOrDefault()?.Trim() ?? "";
        var fallbackTitle = firstLine.Length > 50 ? firstLine.Substring(0, 50) + "..." : firstLine;
        return (fallbackTitle, generatedContent);
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
