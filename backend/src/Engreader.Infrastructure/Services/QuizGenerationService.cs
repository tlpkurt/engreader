using Engreader.Application.Services.Interfaces;
using Engreader.Domain.Enums;
using Engreader.Infrastructure.Configuration;
using Microsoft.Extensions.Options;
using System.Net.Http.Json;
using System.Text.Json;

namespace Engreader.Infrastructure.Services;

/// <summary>
/// Quiz generation using OpenAI
/// </summary>
public class QuizGenerationService : IQuizGenerationService
{
    private readonly HttpClient _httpClient;
    private readonly OpenAISettings _settings;

    public QuizGenerationService(HttpClient httpClient, IOptions<OpenAISettings> settings)
    {
        _httpClient = httpClient;
        _settings = settings.Value;
        _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_settings.ApiKey}");
    }

    public async Task<List<QuizQuestionData>> GenerateQuestionsAsync(
        string storyContent,
        string storyTitle,
        CefrLevel level,
        CancellationToken cancellationToken = default)
    {
        var prompt = BuildQuizPrompt(storyContent, storyTitle, level);

        var requestBody = new
        {
            model = _settings.Model,
            messages = new[]
            {
                new { role = "system", content = "You are an expert at creating educational reading comprehension quizzes." },
                new { role = "user", content = prompt }
            },
            max_tokens = _settings.MaxTokens,
            temperature = 0.7,
            response_format = new { type = "json_object" }
        };

        var response = await _httpClient.PostAsJsonAsync(
            "https://api.openai.com/v1/chat/completions",
            requestBody,
            cancellationToken);

        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<OpenAIResponse>(cancellationToken);
        var content = result?.Choices?.FirstOrDefault()?.Message?.Content;

        if (string.IsNullOrEmpty(content))
            return new List<QuizQuestionData>();

        return ParseQuizQuestions(content);
    }

    private string BuildQuizPrompt(string storyContent, string storyTitle, CefrLevel level)
    {
        return $@"Based on the following story, create exactly 5 multiple-choice reading comprehension questions.

Story Title: {storyTitle}
CEFR Level: {level}

Story:
{storyContent}

Requirements:
1. Create exactly 5 questions
2. Each question must have 4 options (A, B, C, D)
3. Questions should test comprehension, not trivial details
4. Include questions about main idea, details, inference, and vocabulary
5. Make distractors (wrong answers) plausible but clearly incorrect
6. Provide brief explanations for correct answers

Return your response as JSON in this exact format:
{{
  ""questions"": [
    {{
      ""questionNumber"": 1,
      ""questionText"": ""What is the main idea?"",
      ""optionA"": ""First option"",
      ""optionB"": ""Second option"",
      ""optionC"": ""Third option"",
      ""optionD"": ""Fourth option"",
      ""correctAnswer"": ""A"",
      ""explanation"": ""Brief explanation""
    }}
  ]
}}";
    }

    private List<QuizQuestionData> ParseQuizQuestions(string jsonContent)
    {
        try
        {
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            var quizData = JsonSerializer.Deserialize<QuizResponse>(jsonContent, options);
            return quizData?.Questions ?? new List<QuizQuestionData>();
        }
        catch
        {
            return new List<QuizQuestionData>();
        }
    }

    // Response models
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

    private class QuizResponse
    {
        public List<QuizQuestionData>? Questions { get; set; }
    }
}
