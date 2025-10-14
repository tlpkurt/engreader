using Engreader.Api.Controllers;
using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Common;
using Engreader.Contracts.Quizzes;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Engreader.Api.Controllers.V1;

/// <summary>
/// Quiz generation and submission endpoints
/// </summary>
[ApiVersion("1.0")]
[Authorize]
public class QuizzesController : ApiControllerBase
{
    private readonly IQuizService _quizService;
    private readonly ILogger<QuizzesController> _logger;

    public QuizzesController(IQuizService quizService, ILogger<QuizzesController> logger)
    {
        _quizService = quizService;
        _logger = logger;
    }

    /// <summary>
    /// Generate quiz for a story
    /// </summary>
    [HttpPost("generate/{storyId:guid}")]
    [ProducesResponseType(typeof(ApiResponse<QuizResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<QuizResponse>), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ApiResponse<QuizResponse>>> GenerateQuiz(
        Guid storyId,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _quizService.GenerateQuizForStoryAsync(storyId, cancellationToken);
            return Ok(ApiResponse<QuizResponse>.SuccessResponse(response, "Quiz generated successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating quiz for story {StoryId}", storyId);
            return BadRequest(ApiResponse<QuizResponse>.ErrorResponse("Failed to generate quiz"));
        }
    }

    /// <summary>
    /// Get quiz by ID
    /// </summary>
    [HttpGet("{quizId:guid}")]
    [ProducesResponseType(typeof(ApiResponse<QuizResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<QuizResponse>), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ApiResponse<QuizResponse>>> GetQuiz(
        Guid quizId,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _quizService.GetQuizByIdAsync(quizId, cancellationToken);
            return Ok(ApiResponse<QuizResponse>.SuccessResponse(response, "Quiz retrieved"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<QuizResponse>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving quiz {QuizId}", quizId);
            return StatusCode(500, ApiResponse<QuizResponse>.ErrorResponse("Error retrieving quiz"));
        }
    }

    /// <summary>
    /// Submit quiz answers and get results
    /// </summary>
    [HttpPost("submit")]
    [ProducesResponseType(typeof(ApiResponse<QuizResultResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<QuizResultResponse>), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ApiResponse<QuizResultResponse>>> SubmitQuiz(
        [FromBody] SubmitQuizRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            var response = await _quizService.SubmitQuizAsync(userId, request, cancellationToken);
            return Ok(ApiResponse<QuizResultResponse>.SuccessResponse(response, "Quiz submitted successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error submitting quiz");
            return BadRequest(ApiResponse<QuizResultResponse>.ErrorResponse("Failed to submit quiz"));
        }
    }

    /// <summary>
    /// Get quiz history for current user
    /// </summary>
    [HttpGet("history")]
    [ProducesResponseType(typeof(ApiResponse<List<QuizResultResponse>>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<List<QuizResultResponse>>>> GetQuizHistory(
        CancellationToken cancellationToken)
    {
        try
        {
            var userId = GetCurrentUserId();
            var history = await _quizService.GetUserQuizHistoryAsync(userId, cancellationToken);
            return Ok(ApiResponse<List<QuizResultResponse>>.SuccessResponse(history, "Quiz history retrieved"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving quiz history");
            return StatusCode(500, ApiResponse<List<QuizResultResponse>>.ErrorResponse("Error retrieving history"));
        }
    }

    private Guid GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                          ?? User.FindFirst("sub")?.Value;
        return Guid.Parse(userIdClaim!);
    }
}
