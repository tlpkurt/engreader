using Engreader.Application.Services.Interfaces;
using Engreader.Domain.Enums;
using Engreader.Infrastructure.Configuration;
using Microsoft.Extensions.Options;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;

namespace Engreader.Infrastructure.Services;

/// <summary>
/// RAG-based story generation using OpenAI GPT-4o-mini
/// </summary>
public class StoryGenerationService : IStoryGenerationService
{
    private readonly HttpClient _httpClient;
    private readonly OpenAISettings _settings;

    public StoryGenerationService(HttpClient httpClient, IOptions<OpenAISettings> settings)
    {
        _httpClient = httpClient;
        _settings = settings.Value;
        _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_settings.ApiKey}");
    }

    public async Task<string> GenerateStoryContentAsync(
        CefrLevel level,
        string topic,
        List<string> targetWords,
        int wordCount = 300,
        CancellationToken cancellationToken = default)
    {
        // Build RAG-enhanced prompt
        var prompt = BuildStoryPrompt(level, topic, targetWords, wordCount);

        var requestBody = new
        {
            model = _settings.Model,
            messages = new[]
            {
                new { role = "system", content = "You are an expert English teacher creating educational reading materials." },
                new { role = "user", content = prompt }
            },
            max_tokens = _settings.MaxTokens,
            temperature = _settings.Temperature
        };

        var response = await _httpClient.PostAsJsonAsync(
            "https://api.openai.com/v1/chat/completions",
            requestBody,
            cancellationToken);

        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<OpenAIResponse>(cancellationToken);
        return result?.Choices?.FirstOrDefault()?.Message?.Content ?? string.Empty;
    }

    public async Task<List<string>> RetrieveRelevantPassagesAsync(
        string topic,
        CefrLevel level,
        int topK = 3,
        CancellationToken cancellationToken = default)
    {
        // TODO: Implement pgvector similarity search
        // This would query stored passage embeddings
        return new List<string>();
    }

    public async Task<(int count, decimal percentage)> ValidateTargetWordsUsageAsync(
        string content,
        List<string> targetWords)
    {
        var contentLower = content.ToLower();
        var wordsFound = 0;

        foreach (var word in targetWords)
        {
            if (contentLower.Contains(word.ToLower()))
                wordsFound++;
        }

        var percentage = targetWords.Count > 0
            ? (decimal)wordsFound / targetWords.Count * 100
            : 0;

        return (wordsFound, percentage);
    }

    private string BuildStoryPrompt(CefrLevel level, string topic, List<string> targetWords, int wordCount)
    {
        var levelDescription = level switch
        {
            CefrLevel.A1 => "beginner (A1) - very simple sentences and common words",
            CefrLevel.A2 => "elementary (A2) - simple sentences and everyday vocabulary",
            CefrLevel.B1 => "intermediate (B1) - clear standard language",
            CefrLevel.B2 => "upper-intermediate (B2) - detailed texts on various subjects",
            CefrLevel.C1 => "advanced (C1) - complex texts with sophisticated vocabulary",
            _ => "intermediate level"
        };

        var targetWordsStr = string.Join(", ", targetWords);

        return $@"Create an engaging short story for English learners at {levelDescription} level.

Topic: {topic}
Target word count: approximately {wordCount} words

CRITICAL REQUIREMENT: You MUST use at least 70% of these target words in your story:
{targetWordsStr}

Guidelines:
1. Make the story interesting and educational
2. Use natural, contextual sentences
3. Include at least {(int)(targetWords.Count * 0.7)} of the target words naturally
4. Create a complete story with beginning, middle, and end
5. Use appropriate grammar and vocabulary for {level} level
6. Make it relevant to the topic

FORMAT YOUR RESPONSE EXACTLY LIKE THIS:
TITLE: [Write a short, catchy title for the story (max 8 words)]

[Write the story here]

Example:
TITLE: Tom's New Car Adventure

Tom loves cars. He wants to buy a new car...";
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
