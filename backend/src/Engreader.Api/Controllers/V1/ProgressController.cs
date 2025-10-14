using Engreader.Api.Controllers;
using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Common;
using Engreader.Contracts.Progress;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Engreader.Api.Controllers.V1;

/// <summary>
/// User progress and analytics endpoints
/// </summary>
[ApiVersion("1.0")]
[Authorize]
public class ProgressController : ApiControllerBase
{
    private readonly IProgressService _progressService;
    private readonly ILogger<ProgressController> _logger;

    public ProgressController(IProgressService progressService, ILogger<ProgressController> logger)
    {
        _progressService = progressService;
        _logger = logger;
    }

    /// <summary>
    /// Get current user's progress
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<ProgressResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<ProgressResponse>>> GetProgress(
        CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            var progress = await _progressService.GetUserProgressAsync(userId, cancellationToken);
            return Ok(ApiResponse<ProgressResponse>.SuccessResponse(progress, "Progress retrieved"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user progress");
            return StatusCode(500, ApiResponse<ProgressResponse>.ErrorResponse("Error retrieving progress"));
        }
    }

    /// <summary>
    /// Track analytics event (tap, translation, quiz complete, etc.)
    /// </summary>
    [HttpPost("track")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<bool>>> TrackEvent(
        [FromBody] TrackEventRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            await _progressService.TrackEventAsync(userId, request, cancellationToken);
            return Ok(ApiResponse<bool>.SuccessResponse(true, "Event tracked"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error tracking event");
            return StatusCode(500, ApiResponse<bool>.ErrorResponse("Error tracking event"));
        }
    }

    private Guid GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                          ?? User.FindFirst("sub")?.Value;
        return Guid.Parse(userIdClaim!);
    }
}
