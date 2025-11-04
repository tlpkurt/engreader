import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/quiz_model.dart';

class QuizRemoteDataSource {
  final ApiClient _apiClient;

  QuizRemoteDataSource(this._apiClient);

  /// Generate quiz for a story
  Future<QuizModel> generateQuiz(String storyId) async {
    try {
      // Backend expects: POST /quizzes/generate/{storyId}
      final response = await _apiClient.post(
        '${AppConfig.quizzesEndpoint}/generate/$storyId',
      );
      
      // Check if response has data
      if (response.data == null) {
        throw Exception('No data received from server');
      }
      
      // Handle ApiResponse wrapper format
      final responseData = response.data;
      
      if (responseData is Map<String, dynamic>) {
        // Check for success field
        final isSuccess = responseData['success'] ?? responseData['isSuccess'];
        
        if (isSuccess == false) {
          final message = responseData['message']?.toString() ?? 'Failed to generate quiz';
          throw Exception(message);
        }
        
        // Extract data field
        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data == null) {
            throw Exception('Quiz data is null');
          }
          return QuizModel.fromJson(data as Map<String, dynamic>);
        }
        
        // If response data is directly the quiz (no wrapper)
        return QuizModel.fromJson(responseData);
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      // Provide more context in error message
      if (e.toString().contains('type') && e.toString().contains('subtype')) {
        throw Exception('Invalid data format from server. Please check backend response structure.');
      }
      rethrow;
    }
  }

  /// Submit quiz answers
  Future<QuizResultModel> submitQuiz({
    required String quizId,
    required List<AnswerModel> answers,
  }) async {
    try {
      // Backend expects: POST /quizzes/submit with quizId and answers in body
      final response = await _apiClient.post(
        '${AppConfig.quizzesEndpoint}/submit',
        data: {
          'quizId': quizId,
          'answers': answers.map((a) => a.toJson()).toList(),
        },
      );
      
      // Handle ApiResponse wrapper
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return QuizResultModel.fromJson(responseData['data']);
      }
      
      return QuizResultModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  /// Get quiz by ID
  Future<QuizModel> getQuiz(String quizId) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.quizzesEndpoint}/$quizId',
      );
      // Backend returns ApiResponse wrapper, extract data
      return QuizModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all quizzes for a story
  Future<List<QuizModel>> getQuizzesByStory(String storyId) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.quizzesEndpoint}/story/$storyId',
      );
      // Backend returns ApiResponse wrapper, extract data
      return (response.data['data'] as List)
          .map((json) => QuizModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
