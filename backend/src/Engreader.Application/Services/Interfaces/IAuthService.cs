using Engreader.Contracts.Auth;

namespace Engreader.Application.Services.Interfaces;

/// <summary>
/// Authentication service interface
/// </summary>
public interface IAuthService
{
    Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default);
    Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default);
    Task<AuthResponse> RefreshTokenAsync(string refreshToken, CancellationToken cancellationToken = default);
    Task<bool> ValidateTokenAsync(string token, CancellationToken cancellationToken = default);
    Task RevokeTokenAsync(string refreshToken, CancellationToken cancellationToken = default);
}
