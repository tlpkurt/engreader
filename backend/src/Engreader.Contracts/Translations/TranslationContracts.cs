namespace Engreader.Contracts.Translations;

/// <summary>
/// Request for word or sentence translation
/// </summary>
public record TranslationRequest(
    string SourceText,
    bool IsWord,
    Guid? StoryId = null,
    string SourceLanguage = "en",
    string TargetLanguage = "tr"
);

/// <summary>
/// Translation response
/// </summary>
public record TranslationResponse(
    string SourceText,
    string TargetText,
    bool IsWord,
    string SourceLanguage,
    string TargetLanguage
);
