using Engreader.Contracts.Translations;

namespace Engreader.Application.Services.Interfaces;

/// <summary>
/// Translation service for words and sentences
/// </summary>
public interface ITranslationService
{
    Task<TranslationResponse> TranslateAsync(TranslationRequest request, CancellationToken cancellationToken = default);
    Task<List<TranslationResponse>> GetCachedTranslationsAsync(Guid storyId, CancellationToken cancellationToken = default);
}
