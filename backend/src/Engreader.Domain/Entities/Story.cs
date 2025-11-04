using Engreader.Domain.Enums;

namespace Engreader.Domain.Entities;

/// <summary>
/// Generated story for reading practice
/// </summary>
public class Story : BaseEntity
{
    public Guid UserId { get; set; }
    public virtual User User { get; set; } = null!;
    
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty; // Full story text
    public string Topic { get; set; } = string.Empty;
    public CefrLevel Level { get; set; }
    public StoryStatus Status { get; set; } = StoryStatus.Pending;
    
    // Target words for practice
    public List<string> TargetWords { get; set; } = new();
    public int TargetWordCount { get; set; }
    public int ActualTargetWordUsage { get; set; } // Count of target words used
    public decimal TargetWordPercentage { get; set; } // Should be ≥70%
    
    // Metadata
    public int WordCount { get; set; }
    public int ReadingTimeMinutes { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime? CompletedAt { get; set; }
    public int ReadingTimeSeconds { get; set; }
    
    // Navigation properties
    public virtual ICollection<Quiz> Quizzes { get; set; } = new List<Quiz>();
    public virtual ICollection<Translation> Translations { get; set; } = new List<Translation>();
}
