using Engreader.Api.Controllers;
using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Auth;
using Engreader.Contracts.Common;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Engreader.Api.Controllers.V1;

/// <summary>
/// Authentication endpoints
/// </summary>
[ApiVersion("1.0")]
public class AuthController : ApiControllerBase
{
    private readonly IAuthService _authService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IAuthService authService, ILogger<AuthController> logger)
    {
        _authService = authService;
        _logger = logger;
    }

    /// <summary>
    /// Register a new user
    /// </summary>
    [HttpPost("register")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<AuthResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<AuthResponse>), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ApiResponse<AuthResponse>>> Register(
        [FromBody] RegisterRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _authService.RegisterAsync(request, cancellationToken);
            return Ok(ApiResponse<AuthResponse>.SuccessResponse(response, "Registration successful"));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<AuthResponse>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during registration");
            return StatusCode(500, ApiResponse<AuthResponse>.ErrorResponse("An error occurred during registration"));
        }
    }

    /// <summary>
    /// Login with email and password
    /// </summary>
    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<AuthResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<AuthResponse>), StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<ApiResponse<AuthResponse>>> Login(
        [FromBody] LoginRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _authService.LoginAsync(request, cancellationToken);
            return Ok(ApiResponse<AuthResponse>.SuccessResponse(response, "Login successful"));
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(ApiResponse<AuthResponse>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during login");
            return StatusCode(500, ApiResponse<AuthResponse>.ErrorResponse("An error occurred during login"));
        }
    }

    /// <summary>
    /// Refresh access token using refresh token
    /// </summary>
    [HttpPost("refresh")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<AuthResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<AuthResponse>), StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<ApiResponse<AuthResponse>>> RefreshToken(
        [FromBody] RefreshTokenRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _authService.RefreshTokenAsync(request.RefreshToken, cancellationToken);
            return Ok(ApiResponse<AuthResponse>.SuccessResponse(response, "Token refreshed"));
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(ApiResponse<AuthResponse>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during token refresh");
            return StatusCode(500, ApiResponse<AuthResponse>.ErrorResponse("An error occurred during token refresh"));
        }
    }

    /// <summary>
    /// Get current user info
    /// </summary>
    [HttpGet("me")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<UserDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<UserDto>>> GetCurrentUser()
    {
        // TODO: Implement get current user from claims
        return Ok(ApiResponse<UserDto>.SuccessResponse(null!, "User retrieved"));
    }
}
