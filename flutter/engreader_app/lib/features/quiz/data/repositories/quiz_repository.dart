import '../datasources/quiz_remote_datasource.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  final QuizRemoteDataSource _remoteDataSource;

  QuizRepository(this._remoteDataSource);

  /// Generate quiz for a story
  Future<QuizModel> generateQuiz(String storyId) async {
    return await _remoteDataSource.generateQuiz(storyId);
  }

  /// Submit quiz answers and get result
  Future<QuizResultModel> submitQuiz({
    required String quizId,
    required List<AnswerModel> answers,
  }) async {
    return await _remoteDataSource.submitQuiz(
      quizId: quizId,
      answers: answers,
    );
  }

  /// Get quiz by ID
  Future<QuizModel> getQuiz(String quizId) async {
    return await _remoteDataSource.getQuiz(quizId);
  }

  /// Get all quizzes for a story
  Future<List<QuizModel>> getQuizzesByStory(String storyId) async {
    return await _remoteDataSource.getQuizzesByStory(storyId);
  }
}
