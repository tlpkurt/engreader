using Engreader.Application.Services.Interfaces;
using Engreader.Contracts.Translations;
using Engreader.Domain.Entities;
using Engreader.Infrastructure.Persistence;
using Engreader.Infrastructure.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;

namespace Engreader.Infrastructure.Services.Implementations;

/// <summary>
/// Full translation service implementation with caching and OpenAI
/// </summary>
public class TranslationServiceImpl : ITranslationService
{
    private readonly EngreaderDbContext _context;
    private readonly ICacheService _cache;
    private readonly HttpClient _httpClient;
    private readonly OpenAISettings _settings;

    public TranslationServiceImpl(
        EngreaderDbContext context, 
        ICacheService cache,
        HttpClient httpClient,
        IOptions<OpenAISettings> settings)
    {
        _context = context;
        _cache = cache;
        _httpClient = httpClient;
        _settings = settings.Value;
    }

    public async Task<TranslationResponse> TranslateAsync(TranslationRequest request, CancellationToken cancellationToken = default)
    {
        // Check cache first
        var cacheKey = $"translation:{request.SourceLanguage}:{request.TargetLanguage}:{request.SourceText.ToLower()}";
        var cached = await _cache.GetAsync<TranslationResponse>(cacheKey, cancellationToken);

        if (cached != null)
        {
            await IncrementUsageCount(request.SourceText, cancellationToken);
            return cached;
        }

        // Check database
        var translation = await _context.Translations
            .FirstOrDefaultAsync(t =>
                t.SourceText.ToLower() == request.SourceText.ToLower() &&
                t.SourceLanguage == request.SourceLanguage &&
                t.TargetLanguage == request.TargetLanguage,
                cancellationToken);

        if (translation != null)
        {
            var response = new TranslationResponse(
                translation.SourceText,
                translation.TargetText,
                translation.IsWord,
                translation.SourceLanguage,
                translation.TargetLanguage
            );

            // Cache for 1 hour
            await _cache.SetAsync(cacheKey, response, TimeSpan.FromHours(1), cancellationToken);
            
            translation.UsageCount++;
            await _context.SaveChangesAsync(cancellationToken);

            return response;
        }

        // Generate new translation (TODO: Integrate with translation API)
        var targetText = await GenerateTranslation(request.SourceText, request.SourceLanguage, request.TargetLanguage);

        // Save to database
        var newTranslation = new Translation
        {
            SourceText = request.SourceText,
            TargetText = targetText,
            SourceLanguage = request.SourceLanguage,
            TargetLanguage = request.TargetLanguage,
            IsWord = request.IsWord,
            StoryId = request.StoryId,
            UsageCount = 1
        };

        _context.Translations.Add(newTranslation);
        await _context.SaveChangesAsync(cancellationToken);

        var newResponse = new TranslationResponse(
            newTranslation.SourceText,
            newTranslation.TargetText,
            newTranslation.IsWord,
            newTranslation.SourceLanguage,
            newTranslation.TargetLanguage
        );

        // Cache for 1 hour
        await _cache.SetAsync(cacheKey, newResponse, TimeSpan.FromHours(1), cancellationToken);

        return newResponse;
    }

    public async Task<List<TranslationResponse>> GetCachedTranslationsAsync(Guid storyId, CancellationToken cancellationToken = default)
    {
        var translations = await _context.Translations
            .Where(t => t.StoryId == storyId)
            .OrderByDescending(t => t.UsageCount)
            .ToListAsync(cancellationToken);

        return translations.Select(t => new TranslationResponse(
            t.SourceText,
            t.TargetText,
            t.IsWord,
            t.SourceLanguage,
            t.TargetLanguage
        )).ToList();
    }

    private async Task IncrementUsageCount(string sourceText, CancellationToken cancellationToken)
    {
        var translation = await _context.Translations
            .FirstOrDefaultAsync(t => t.SourceText.ToLower() == sourceText.ToLower(), cancellationToken);

        if (translation != null)
        {
            translation.UsageCount++;
            await _context.SaveChangesAsync(cancellationToken);
        }
    }

    private async Task<string> GenerateTranslation(string sourceText, string sourceLang, string targetLang)
    {
        var targetLanguageName = GetLanguageName(targetLang);
        var sourceLanguageName = GetLanguageName(sourceLang);

        var prompt = $"Translate the following {sourceLanguageName} text to {targetLanguageName}. " +
                     $"Only provide the translation, no explanations:\n\n{sourceText}";

        var requestBody = new
        {
            model = "gpt-4o-mini",
            messages = new[]
            {
                new { role = "system", content = "You are a professional translator. Provide accurate, natural translations." },
                new { role = "user", content = prompt }
            },
            temperature = 0.3,
            max_tokens = 200
        };

        var request = new HttpRequestMessage(HttpMethod.Post, "https://api.openai.com/v1/chat/completions")
        {
            Content = new StringContent(
                JsonSerializer.Serialize(requestBody),
                Encoding.UTF8,
                "application/json")
        };
        
        request.Headers.Add("Authorization", $"Bearer {_settings.ApiKey}");

        var response = await _httpClient.SendAsync(request);
        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<OpenAIResponse>();
        return result?.Choices?.FirstOrDefault()?.Message?.Content?.Trim() 
               ?? $"[Translation error for '{sourceText}']";
    }

    private string GetLanguageName(string langCode)
    {
        return langCode.ToLower() switch
        {
            "en" => "English",
            "tr" => "Turkish",
            "es" => "Spanish",
            "fr" => "French",
            "de" => "German",
            "it" => "Italian",
            "pt" => "Portuguese",
            "ru" => "Russian",
            "ja" => "Japanese",
            "zh" => "Chinese",
            "ar" => "Arabic",
            _ => langCode
        };
    }

    // OpenAI API response models
    private class OpenAIResponse
    {
        public List<Choice>? Choices { get; set; }
    }

    private class Choice
    {
        public Message? Message { get; set; }
    }

    private class Message
    {
        public string? Content { get; set; }
    }
}
