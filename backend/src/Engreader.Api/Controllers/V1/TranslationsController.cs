using Engreader.Api.Controllers;
using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Common;
using Engreader.Contracts.Translations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Engreader.Api.Controllers.V1;

/// <summary>
/// Translation endpoints for words and sentences
/// </summary>
[ApiVersion("1.0")]
[Authorize]
public class TranslationsController : ApiControllerBase
{
    private readonly ITranslationService _translationService;
    private readonly ILogger<TranslationsController> _logger;

    public TranslationsController(ITranslationService translationService, ILogger<TranslationsController> logger)
    {
        _translationService = translationService;
        _logger = logger;
    }

    /// <summary>
    /// Translate word or sentence (cached)
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<TranslationResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<TranslationResponse>>> Translate(
        [FromBody] TranslationRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _translationService.TranslateAsync(request, cancellationToken);
            return Ok(ApiResponse<TranslationResponse>.SuccessResponse(response, "Translation retrieved"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error translating text");
            return StatusCode(500, ApiResponse<TranslationResponse>.ErrorResponse("Translation failed"));
        }
    }

    /// <summary>
    /// Get cached translations for a story
    /// </summary>
    [HttpGet("story/{storyId:guid}")]
    [ProducesResponseType(typeof(ApiResponse<List<TranslationResponse>>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<List<TranslationResponse>>>> GetStoryTranslations(
        Guid storyId,
        CancellationToken cancellationToken)
    {
        try
        {
            var translations = await _translationService.GetCachedTranslationsAsync(storyId, cancellationToken);
            return Ok(ApiResponse<List<TranslationResponse>>.SuccessResponse(translations, "Translations retrieved"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving translations for story {StoryId}", storyId);
            return StatusCode(500, ApiResponse<List<TranslationResponse>>.ErrorResponse("Error retrieving translations"));
        }
    }
}
