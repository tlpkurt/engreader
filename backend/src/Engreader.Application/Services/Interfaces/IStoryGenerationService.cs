using Engreader.Domain.Enums;

namespace Engreader.Application.Services.Interfaces;

/// <summary>
/// RAG-based story generation using OpenAI
/// </summary>
public interface IStoryGenerationService
{
    /// <summary>
    /// Generate story content using RAG (Retrieval-Augmented Generation)
    /// Ensures target words usage >= 70%
    /// </summary>
    Task<string> GenerateStoryContentAsync(
        CefrLevel level,
        string topic,
        List<string> targetWords,
        int wordCount = 300,
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Retrieve relevant passages from pgvector embeddings
    /// </summary>
    Task<List<string>> RetrieveRelevantPassagesAsync(
        string topic,
        CefrLevel level,
        int topK = 3,
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Validate target words usage percentage
    /// </summary>
    Task<(int count, decimal percentage)> ValidateTargetWordsUsageAsync(
        string content,
        List<string> targetWords);
}
