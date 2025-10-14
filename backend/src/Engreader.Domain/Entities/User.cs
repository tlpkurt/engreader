namespace Engreader.Domain.Entities;

/// <summary>
/// User entity for authentication and profile
/// </summary>
public class User : BaseEntity
{
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? NativeLanguage { get; set; } = "tr"; // Turkish by default
    public DateTime? LastLoginAt { get; set; }
    public bool IsEmailVerified { get; set; } = false;
    
    // Multi-tenant support
    public Guid? TenantId { get; set; } // For school accounts
    public string Role { get; set; } = "Student"; // Student, Teacher, Admin
    
    // Navigation properties
    public virtual ICollection<UserProgress> ProgressRecords { get; set; } = new List<UserProgress>();
    public virtual ICollection<Story> Stories { get; set; } = new List<Story>();
    public virtual ICollection<QuizAttempt> QuizAttempts { get; set; } = new List<QuizAttempt>();
}
