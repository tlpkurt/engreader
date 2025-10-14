import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/quiz_model.dart';

class QuizRemoteDataSource {
  final ApiClient _apiClient;

  QuizRemoteDataSource(this._apiClient);

  /// Generate quiz for a story
  Future<QuizModel> generateQuiz(String storyId) async {
    try {
      final response = await _apiClient.post(
        AppConfig.quizzesEndpoint,
        data: {
          'storyId': storyId,
        },
      );
      // Backend returns ApiResponse wrapper, extract data
      return QuizModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Submit quiz answers
  Future<QuizResultModel> submitQuiz({
    required String quizId,
    required List<AnswerModel> answers,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.quizzesEndpoint}/$quizId/submit',
        data: {
          'answers': answers.map((a) => a.toJson()).toList(),
        },
      );
      // Backend returns ApiResponse wrapper, extract data
      return QuizResultModel.fromJson(response.data['data']);
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
