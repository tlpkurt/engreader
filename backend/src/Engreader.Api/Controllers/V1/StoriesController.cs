using Engreader.Api.Controllers;
using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Common;
using Engreader.Contracts.Stories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Engreader.Api.Controllers.V1;

/// <summary>
/// Story generation and management endpoints
/// </summary>
[ApiVersion("1.0")]
[Authorize]
public class StoriesController : ApiControllerBase
{
    private readonly IStoryService _storyService;
    private readonly ILogger<StoriesController> _logger;

    public StoriesController(IStoryService storyService, ILogger<StoriesController> logger)
    {
        _storyService = storyService;
        _logger = logger;
    }

    /// <summary>
    /// Generate a new story based on CEFR level, topic, and target words
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<StoryResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<StoryResponse>), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ApiResponse<StoryResponse>>> GenerateStory(
        [FromBody] GenerateStoryRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            var response = await _storyService.GenerateStoryAsync(userId, request, cancellationToken);
            return Ok(ApiResponse<StoryResponse>.SuccessResponse(response, "Story generated successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating story");
            return BadRequest(ApiResponse<StoryResponse>.ErrorResponse("Failed to generate story"));
        }
    }

    /// <summary>
    /// Get story by ID
    /// </summary>
    [HttpGet("{storyId:guid}")]
    [ProducesResponseType(typeof(ApiResponse<StoryResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<StoryResponse>), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ApiResponse<StoryResponse>>> GetStory(
        Guid storyId,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _storyService.GetStoryByIdAsync(storyId, cancellationToken);
            return Ok(ApiResponse<StoryResponse>.SuccessResponse(response, "Story retrieved"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<StoryResponse>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving story {StoryId}", storyId);
            return StatusCode(500, ApiResponse<StoryResponse>.ErrorResponse("Error retrieving story"));
        }
    }

    /// <summary>
    /// Get all stories for current user
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<List<StoryListItem>>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<List<StoryListItem>>>> GetMyStories(
        CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            var stories = await _storyService.GetUserStoriesAsync(userId, cancellationToken);
            return Ok(ApiResponse<List<StoryListItem>>.SuccessResponse(stories, "Stories retrieved"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user stories");
            return StatusCode(500, ApiResponse<List<StoryListItem>>.ErrorResponse("Error retrieving stories"));
        }
    }

    /// <summary>
    /// Mark story as completed
    /// </summary>
    [HttpPost("{storyId:guid}/complete")]
    [ProducesResponseType(typeof(ApiResponse<StoryResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<StoryResponse>>> CompleteStory(
        Guid storyId,
        [FromBody] CompleteStoryRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            var response = await _storyService.CompleteStoryAsync(userId, request, cancellationToken);
            return Ok(ApiResponse<StoryResponse>.SuccessResponse(response, "Story marked as completed"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error completing story {StoryId}", storyId);
            return StatusCode(500, ApiResponse<StoryResponse>.ErrorResponse("Error completing story"));
        }
    }

    /// <summary>
    /// Delete a story
    /// </summary>
    [HttpDelete("{storyId:guid}")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteStory(
        Guid storyId,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await _storyService.DeleteStoryAsync(storyId, cancellationToken);
            return Ok(ApiResponse<bool>.SuccessResponse(result, "Story deleted"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting story {StoryId}", storyId);
            return StatusCode(500, ApiResponse<bool>.ErrorResponse("Error deleting story"));
        }
    }

    private Guid GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                          ?? User.FindFirst("sub")?.Value;
        return Guid.Parse(userIdClaim!);
    }
}
