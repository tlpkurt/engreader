namespace Engreader.Domain.Entities;

/// <summary>
/// Individual quiz question (5 questions per quiz)
/// </summary>
public class QuizQuestion : BaseEntity
{
    public Guid QuizId { get; set; }
    public virtual Quiz Quiz { get; set; } = null!;
    
    public int QuestionNumber { get; set; } // 1-5
    public string QuestionText { get; set; } = string.Empty;
    
    // Multiple choice options
    public string OptionA { get; set; } = string.Empty;
    public string OptionB { get; set; } = string.Empty;
    public string OptionC { get; set; } = string.Empty;
    public string OptionD { get; set; } = string.Empty;
    
    public string CorrectAnswer { get; set; } = string.Empty; // A, B, C, or D
    public string? Explanation { get; set; }
}
