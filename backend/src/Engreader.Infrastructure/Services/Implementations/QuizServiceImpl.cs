using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Quizzes;
using Engreader.Domain.Entities;
using Engreader.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Engreader.Infrastructure.Services.Implementations;

/// <summary>
/// Full quiz service implementation
/// </summary>
public class QuizServiceImpl : IQuizService
{
    private readonly EngreaderDbContext _context;
    private readonly IQuizGenerationService _quizGeneration;

    public QuizServiceImpl(
        EngreaderDbContext context,
        IQuizGenerationService quizGeneration)
    {
        _context = context;
        _quizGeneration = quizGeneration;
    }

    public async Task<QuizResponse> GenerateQuizForStoryAsync(Guid storyId, CancellationToken cancellationToken = default)
    {
        var story = await _context.Stories
            .FirstOrDefaultAsync(s => s.Id == storyId, cancellationToken);

        if (story == null)
            throw new KeyNotFoundException("Story not found");

        // Generate questions using OpenAI
        var questions = await _quizGeneration.GenerateQuestionsAsync(
            story.Content,
            story.Title,
            story.Level,
            cancellationToken);

        // Create quiz
        var quiz = new Quiz
        {
            StoryId = storyId,
            Title = $"Quiz: {story.Title}"
        };

        _context.Quizzes.Add(quiz);
        await _context.SaveChangesAsync(cancellationToken);

        // Create questions
        foreach (var q in questions)
        {
            var question = new QuizQuestion
            {
                QuizId = quiz.Id,
                QuestionNumber = q.QuestionNumber,
                QuestionText = q.QuestionText,
                OptionA = q.OptionA,
                OptionB = q.OptionB,
                OptionC = q.OptionC,
                OptionD = q.OptionD,
                CorrectAnswer = q.CorrectAnswer,
                Explanation = q.Explanation
            };
            _context.QuizQuestions.Add(question);
        }

        await _context.SaveChangesAsync(cancellationToken);

        return await GetQuizByIdAsync(quiz.Id, cancellationToken);
    }

    public async Task<QuizResponse> GetQuizByIdAsync(Guid quizId, CancellationToken cancellationToken = default)
    {
        var quiz = await _context.Quizzes
            .Include(q => q.Questions)
            .FirstOrDefaultAsync(q => q.Id == quizId, cancellationToken);

        if (quiz == null)
            throw new KeyNotFoundException("Quiz not found");

        var questions = quiz.Questions
            .OrderBy(q => q.QuestionNumber)
            .Select(q => new QuizQuestionDto(
                q.Id,
                q.QuestionNumber,
                q.QuestionText,
                q.OptionA,
                q.OptionB,
                q.OptionC,
                q.OptionD
            ))
            .ToList();

        return new QuizResponse(quiz.Id, quiz.StoryId, quiz.Title, questions);
    }

    public async Task<QuizResultResponse> SubmitQuizAsync(Guid userId, SubmitQuizRequest request, CancellationToken cancellationToken = default)
    {
        var quiz = await _context.Quizzes
            .Include(q => q.Questions)
            .FirstOrDefaultAsync(q => q.Id == request.QuizId, cancellationToken);

        if (quiz == null)
            throw new KeyNotFoundException("Quiz not found");

        // Calculate score
        var results = new List<QuizAnswerResult>();
        var correctCount = 0;

        foreach (var question in quiz.Questions.OrderBy(q => q.QuestionNumber))
        {
            // Parse question number from string key (JSON sends numbers as strings)
            var userAnswer = request.Answers.GetValueOrDefault(question.QuestionNumber.ToString(), "");
            var isCorrect = userAnswer.Equals(question.CorrectAnswer, StringComparison.OrdinalIgnoreCase);

            if (isCorrect)
                correctCount++;

            results.Add(new QuizAnswerResult(
                question.QuestionNumber,
                question.QuestionText,
                userAnswer,
                question.CorrectAnswer,
                isCorrect,
                question.Explanation
            ));
        }

        var totalQuestions = quiz.Questions.Count;
        var percentage = totalQuestions > 0 ? (decimal)correctCount / totalQuestions * 100 : 0;

        // Save attempt
        var attempt = new QuizAttempt
        {
            UserId = userId,
            QuizId = request.QuizId,
            Score = correctCount,
            Percentage = percentage,
            TimeSpentSeconds = request.TimeSpentSeconds,
            UserAnswers = request.Answers
        };

        _context.QuizAttempts.Add(attempt);
        await _context.SaveChangesAsync(cancellationToken);

        // Update user progress
        await UpdateUserProgressAsync(userId, percentage, cancellationToken);

        return new QuizResultResponse(
            attempt.Id,
            correctCount,
            percentage,
            totalQuestions,
            results
        );
    }

    public async Task<List<QuizResultResponse>> GetUserQuizHistoryAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var attempts = await _context.QuizAttempts
            .Where(a => a.UserId == userId)
            .OrderByDescending(a => a.CreatedAt)
            .Take(20)
            .ToListAsync(cancellationToken);

        return attempts.Select(a => new QuizResultResponse(
            a.Id,
            a.Score,
            a.Percentage,
            5, // Default 5 questions
            new List<QuizAnswerResult>()
        )).ToList();
    }

    private async Task UpdateUserProgressAsync(Guid userId, decimal quizScore, CancellationToken cancellationToken)
    {
        var progress = await _context.UserProgress
            .FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

        if (progress != null)
        {
            progress.TotalQuizzesCompleted++;
            
            // Recalculate average score
            var allScores = await _context.QuizAttempts
                .Where(a => a.UserId == userId)
                .Select(a => a.Percentage)
                .ToListAsync(cancellationToken);

            progress.AverageQuizScore = allScores.Any() ? allScores.Average() : 0;
            
            await _context.SaveChangesAsync(cancellationToken);
        }
    }
}
