namespace Engreader.Domain.Entities;

/// <summary>
/// User's quiz attempt record
/// </summary>
public class QuizAttempt : BaseEntity
{
    public Guid UserId { get; set; }
    public virtual User User { get; set; } = null!;
    
    public Guid QuizId { get; set; }
    public virtual Quiz Quiz { get; set; } = null!;
    
    public int Score { get; set; } // 0-5 correct answers
    public decimal Percentage { get; set; } // 0-100%
    public int TimeSpentSeconds { get; set; }
    
    // User answers (stored as string keys for JSON compatibility)
    public Dictionary<string, string> UserAnswers { get; set; } = new(); // QuestionNumber (as string) -> Answer
    
    public DateTime CompletedAt { get; set; } = DateTime.UtcNow;
}
