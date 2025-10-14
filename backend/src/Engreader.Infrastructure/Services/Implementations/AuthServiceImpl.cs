using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Auth;
using Engreader.Domain.Entities;
using Engreader.Infrastructure.Persistence;
using Engreader.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;

namespace Engreader.Infrastructure.Services.Implementations;

/// <summary>
/// Full authentication service implementation
/// </summary>
public class AuthServiceImpl : IAuthService
{
    private readonly EngreaderDbContext _context;
    private readonly JwtTokenService _jwtService;
    private readonly ICacheService _cache;

    public AuthServiceImpl(
        EngreaderDbContext context,
        JwtTokenService jwtService,
        ICacheService cache)
    {
        _context = context;
        _jwtService = jwtService;
        _cache = cache;
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default)
    {
        // Check if email already exists
        var existingUser = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == request.Email, cancellationToken);

        if (existingUser != null)
            throw new InvalidOperationException("Email already registered");

        // Create new user
        var user = new User
        {
            Email = request.Email,
            PasswordHash = PasswordHasher.HashPassword(request.Password),
            FirstName = request.FirstName,
            LastName = request.LastName,
            NativeLanguage = request.NativeLanguage ?? "tr",
            Role = "Student",
            IsEmailVerified = false
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync(cancellationToken);

        // Create initial progress record
        var progress = new UserProgress
        {
            UserId = user.Id,
            CurrentLevel = Domain.Enums.CefrLevel.A1
        };
        _context.UserProgress.Add(progress);
        await _context.SaveChangesAsync(cancellationToken);

        // Generate tokens
        var accessToken = _jwtService.GenerateAccessToken(user.Id, user.Email, user.Role);
        var refreshToken = _jwtService.GenerateRefreshToken();

        // Cache refresh token
        await _cache.SetAsync($"refresh_token:{user.Id}", refreshToken, TimeSpan.FromDays(7), cancellationToken);

        return new AuthResponse(
            accessToken,
            refreshToken,
            DateTime.UtcNow.AddMinutes(60),
            new UserDto(user.Id, user.Email, user.FirstName, user.LastName, user.Role, user.NativeLanguage, user.IsEmailVerified)
        );
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == request.Email, cancellationToken);

        if (user == null || !PasswordHasher.VerifyPassword(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid email or password");

        // Update last login
        user.LastLoginAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(cancellationToken);

        // Generate tokens
        var accessToken = _jwtService.GenerateAccessToken(user.Id, user.Email, user.Role);
        var refreshToken = _jwtService.GenerateRefreshToken();

        // Cache refresh token
        await _cache.SetAsync($"refresh_token:{user.Id}", refreshToken, TimeSpan.FromDays(7), cancellationToken);

        return new AuthResponse(
            accessToken,
            refreshToken,
            DateTime.UtcNow.AddMinutes(60),
            new UserDto(user.Id, user.Email, user.FirstName, user.LastName, user.Role, user.NativeLanguage, user.IsEmailVerified)
        );
    }

    public async Task<AuthResponse> RefreshTokenAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        // Validate refresh token from cache
        // TODO: Implement proper refresh token validation
        throw new NotImplementedException("Refresh token validation not implemented yet");
    }

    public async Task<bool> ValidateTokenAsync(string token, CancellationToken cancellationToken = default)
    {
        var principal = _jwtService.ValidateToken(token);
        return await Task.FromResult(principal != null);
    }

    public async Task RevokeTokenAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        // TODO: Implement token revocation
        await Task.CompletedTask;
    }
}
