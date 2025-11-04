import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/story_model.dart';

class StoryRemoteDataSource {
  final ApiClient _apiClient;

  StoryRemoteDataSource(this._apiClient);

  /// Generate a new story
  Future<StoryModel> generateStory({
    required String cefrLevel,
    required String topic,
    required List<String> targetWords,
    required int wordCount,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.storiesEndpoint,
        data: {
          'level': cefrLevel,  // Backend expects 'level' not 'cefrLevel'
          'topic': topic,
          'targetWords': targetWords,
          'wordCount': wordCount,
        },
      );
      // Backend returns ApiResponse wrapper, extract data
      return StoryModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all stories for current user
  Future<List<StoryModel>> getStories({
    String? cefrLevel,
    bool? isCompleted,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cefrLevel != null) queryParams['cefrLevel'] = cefrLevel;
      if (isCompleted != null) queryParams['isCompleted'] = isCompleted;

      final response = await _apiClient.get(
        AppConfig.storiesEndpoint,
        queryParameters: queryParams,
      );

      // Backend returns ApiResponse wrapper, extract data
      final data = response.data['data'];
      if (data == null) return [];
      if (data is! List) return [];
      
      return data
          .map((json) => StoryModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a single story by ID
  Future<StoryModel> getStory(String storyId) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.storiesEndpoint}/$storyId',
      );
      // Backend returns ApiResponse wrapper, extract data
      final data = response.data['data'];
      print('📥 Story Response Data: $data');
      
      // Check if quiz exists and has valid structure
      if (data['quiz'] != null) {
        print('📝 Quiz Data: ${data['quiz']}');
      }
      
      return StoryModel.fromJson(data);
    } catch (e, stackTrace) {
      print('❌ Error parsing story: $e');
      print('📚 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Mark story as completed
  Future<void> completeStory({
    required String storyId,
    required int readingTimeSeconds,
  }) async {
    try {
      await _apiClient.post(
        '${AppConfig.storiesEndpoint}/$storyId/complete',
        data: {
          'readingTimeSeconds': readingTimeSeconds,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a story
  Future<void> deleteStory(String storyId) async {
    try {
      await _apiClient.delete(
        '${AppConfig.storiesEndpoint}/$storyId',
      );
    } catch (e) {
      rethrow;
    }
  }
}
