import '../datasources/story_remote_datasource.dart';
import '../models/story_model.dart';

class StoryRepository {
  final StoryRemoteDataSource _remoteDataSource;

  StoryRepository(this._remoteDataSource);

  /// Generate a new story
  Future<StoryModel> generateStory({
    required String cefrLevel,
    required String topic,
    required List<String> targetWords,
    required int wordCount,
  }) async {
    return await _remoteDataSource.generateStory(
      cefrLevel: cefrLevel,
      topic: topic,
      targetWords: targetWords,
      wordCount: wordCount,
    );
  }

  /// Get all stories with optional filters
  Future<List<StoryModel>> getStories({
    String? cefrLevel,
    bool? isCompleted,
  }) async {
    return await _remoteDataSource.getStories(
      cefrLevel: cefrLevel,
      isCompleted: isCompleted,
    );
  }

  /// Get a single story by ID
  Future<StoryModel> getStory(String storyId) async {
    return await _remoteDataSource.getStory(storyId);
  }

  /// Mark story as completed with reading time
  Future<void> completeStory({
    required String storyId,
    required int readingTimeSeconds,
  }) async {
    await _remoteDataSource.completeStory(
      storyId: storyId,
      readingTimeSeconds: readingTimeSeconds,
    );
  }

  /// Delete a story
  Future<void> deleteStory(String storyId) async {
    await _remoteDataSource.deleteStory(storyId);
  }
}
