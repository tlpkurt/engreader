using Engreader.Application.Services.Interfaces;
using Engreader.Infrastructure.Configuration;
using Engreader.Infrastructure.Persistence;
using Engreader.Infrastructure.Persistence.Repositories;
using Engreader.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using StackExchange.Redis;

namespace Engreader.Infrastructure;

/// <summary>
/// Dependency injection configuration for Infrastructure layer
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Database - PostgreSQL
        services.AddDbContext<EngreaderDbContext>(options =>
        {
            options.UseNpgsql(
                configuration.GetConnectionString("PostgreSQL"),
                npgsqlOptions =>
                {
                    // npgsqlOptions.UseVector(); // Enable pgvector extension (not installed)
                    npgsqlOptions.MigrationsAssembly(typeof(EngreaderDbContext).Assembly.FullName);
                });
        });

        // Redis (optional - use in-memory cache as fallback)
        var redisConnection = configuration.GetConnectionString("Redis");
        if (!string.IsNullOrEmpty(redisConnection))
        {
            try
            {
                var redis = ConnectionMultiplexer.Connect(redisConnection);
                services.AddSingleton<IConnectionMultiplexer>(redis);
                services.AddSingleton<ICacheService, RedisCacheService>();
            }
            catch
            {
                // Redis not available, use in-memory cache instead
                services.AddMemoryCache();
                services.AddSingleton<ICacheService, InMemoryCacheService>();
            }
        }
        else
        {
            // No Redis configured, use in-memory cache
            services.AddMemoryCache();
            services.AddSingleton<ICacheService, InMemoryCacheService>();
        }

        // Configuration settings
        services.Configure<OpenAISettings>(configuration.GetSection("OpenAI"));
        services.Configure<JwtSettings>(configuration.GetSection("JwtSettings"));

        // HttpClient for OpenAI
        services.AddHttpClient<IStoryGenerationService, StoryGenerationService>();
        services.AddHttpClient<IQuizGenerationService, QuizGenerationService>();
        services.AddHttpClient<Services.Implementations.TranslationServiceImpl>();

        // Repositories
        services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

        // Additional services
        services.AddScoped<JwtTokenService>();

        // Service implementations (override Application layer placeholders)
        services.AddScoped<IAuthService, Services.Implementations.AuthServiceImpl>();
        services.AddScoped<IStoryService, Services.Implementations.StoryServiceImpl>();
        services.AddScoped<IQuizService, Services.Implementations.QuizServiceImpl>();
        services.AddScoped<ITranslationService, Services.Implementations.TranslationServiceImpl>();
        services.AddScoped<IProgressService, Services.Implementations.ProgressServiceImpl>();

        return services;
    }
}
