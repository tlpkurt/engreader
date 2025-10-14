namespace Engreader.Domain.Entities;

/// <summary>
/// Event tracking for analytics
/// </summary>
public class UserEvent : BaseEntity
{
    public Guid UserId { get; set; }
    public virtual User User { get; set; } = null!;
    
    public string EventType { get; set; } = string.Empty; // WordTap, SentencePress, QuizComplete, etc.
    public string EventData { get; set; } = string.Empty; // JSON data
    public DateTime EventTime { get; set; } = DateTime.UtcNow;
    
    public Guid? StoryId { get; set; }
    public Guid? QuizId { get; set; }
}
