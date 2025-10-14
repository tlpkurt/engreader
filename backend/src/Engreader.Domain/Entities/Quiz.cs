namespace Engreader.Domain.Entities;

/// <summary>
/// Quiz generated for a story
/// </summary>
public class Quiz : BaseEntity
{
    public Guid StoryId { get; set; }
    public virtual Story Story { get; set; } = null!;
    
    public string Title { get; set; } = string.Empty;
    
    // Navigation properties
    public virtual ICollection<QuizQuestion> Questions { get; set; } = new List<QuizQuestion>();
    public virtual ICollection<QuizAttempt> Attempts { get; set; } = new List<QuizAttempt>();
}
