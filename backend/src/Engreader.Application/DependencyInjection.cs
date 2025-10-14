using Engreader.Application.Services;
using Engreader.Application.Services.Interfaces;
using Microsoft.Extensions.DependencyInjection;

namespace Engreader.Application;

/// <summary>
/// Dependency injection configuration for Application layer
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        // Register application services
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IStoryService, StoryService>();
        services.AddScoped<IQuizService, QuizService>();
        services.AddScoped<ITranslationService, TranslationService>();
        services.AddScoped<IProgressService, ProgressService>();

        return services;
    }
}
