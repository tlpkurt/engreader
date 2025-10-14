using Engreader.Domain.Enums;

namespace Engreader.Domain.Entities;

/// <summary>
/// User progress tracking
/// </summary>
public class UserProgress : BaseEntity
{
    public Guid UserId { get; set; }
    public virtual User User { get; set; } = null!;
    
    public CefrLevel CurrentLevel { get; set; }
    public int TotalStoriesRead { get; set; }
    public int TotalQuizzesCompleted { get; set; }
    public decimal AverageQuizScore { get; set; }
    
    // Vocabulary tracking
    public int TotalWordsLearned { get; set; }
    public int TotalTranslationsViewed { get; set; }
    
    // Engagement metrics
    public int TotalReadingTimeMinutes { get; set; }
    public int StreakDays { get; set; }
    public DateTime? LastReadingDate { get; set; }
}
