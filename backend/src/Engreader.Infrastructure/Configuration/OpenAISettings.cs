namespace Engreader.Infrastructure.Configuration;

/// <summary>
/// OpenAI configuration settings
/// </summary>
public class OpenAISettings
{
    public string ApiKey { get; set; } = string.Empty;
    public string Model { get; set; } = "gpt-4o-mini";
    public int MaxTokens { get; set; } = 2000;
    public double Temperature { get; set; } = 0.7;
}
