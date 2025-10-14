using Engreader.Domain.Enums;

namespace Engreader.Contracts.Auth;

/// <summary>
/// User registration request
/// </summary>
public record RegisterRequest(
    string Email,
    string Password,
    string FirstName,
    string LastName,
    string? NativeLanguage = "tr"
);

/// <summary>
/// User login request
/// </summary>
public record LoginRequest(
    string Email,
    string Password
);

/// <summary>
/// Authentication response with tokens
/// </summary>
public record AuthResponse(
    string AccessToken,
    string RefreshToken,
    DateTime ExpiresAt,
    UserDto User
);

/// <summary>
/// User data transfer object
/// </summary>
public record UserDto(
    Guid Id,
    string Email,
    string FirstName,
    string LastName,
    string Role,
    string? NativeLanguage,
    bool IsEmailVerified
);

/// <summary>
/// Refresh token request
/// </summary>
public record RefreshTokenRequest(
    string RefreshToken
);
