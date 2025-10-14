namespace Engreader.Domain.Entities;

/// <summary>
/// Word or sentence translation cache
/// </summary>
public class Translation : BaseEntity
{
    public Guid? StoryId { get; set; }
    public virtual Story? Story { get; set; }
    
    public string SourceText { get; set; } = string.Empty;
    public string TargetText { get; set; } = string.Empty; // Turkish translation
    public string SourceLanguage { get; set; } = "en";
    public string TargetLanguage { get; set; } = "tr";
    
    public bool IsWord { get; set; } = true; // true for word, false for sentence
    public int UsageCount { get; set; } = 0; // How many times requested
}
