import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/quiz_model.dart';
import '../../data/datasources/quiz_remote_datasource.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../../../core/network/api_client.dart';

// Quiz Remote DataSource Provider
final quizRemoteDataSourceProvider = Provider<QuizRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuizRemoteDataSource(apiClient);
});

// Quiz Repository Provider
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final remoteDataSource = ref.watch(quizRemoteDataSourceProvider);
  return QuizRepository(remoteDataSource);
});

// Quiz Generation State
class QuizGenerationState {
  final QuizModel? quiz;
  final bool isLoading;
  final String? error;

  QuizGenerationState({
    this.quiz,
    this.isLoading = false,
    this.error,
  });

  QuizGenerationState copyWith({
    QuizModel? quiz,
    bool? isLoading,
    String? error,
  }) {
    return QuizGenerationState(
      quiz: quiz ?? this.quiz,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Quiz Generation Notifier
class QuizGenerationNotifier extends StateNotifier<QuizGenerationState> {
  final QuizRepository _quizRepository;

  QuizGenerationNotifier(this._quizRepository) : super(QuizGenerationState());

  /// Generate a new quiz
  Future<void> generateQuiz(String storyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final quiz = await _quizRepository.generateQuiz(storyId);
      state = state.copyWith(
        quiz: quiz,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear generated quiz
  void clearQuiz() {
    state = QuizGenerationState();
  }
}

// Quiz Generation Provider
final quizGenerationProvider =
    StateNotifierProvider<QuizGenerationNotifier, QuizGenerationState>((ref) {
  final quizRepository = ref.watch(quizRepositoryProvider);
  return QuizGenerationNotifier(quizRepository);
});

// Quiz Submission State
class QuizSubmissionState {
  final QuizResultModel? result;
  final bool isLoading;
  final String? error;

  QuizSubmissionState({
    this.result,
    this.isLoading = false,
    this.error,
  });

  QuizSubmissionState copyWith({
    QuizResultModel? result,
    bool? isLoading,
    String? error,
  }) {
    return QuizSubmissionState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Quiz Submission Notifier
class QuizSubmissionNotifier extends StateNotifier<QuizSubmissionState> {
  final QuizRepository _quizRepository;

  QuizSubmissionNotifier(this._quizRepository)
      : super(QuizSubmissionState());

  /// Submit quiz answers
  Future<void> submitQuiz({
    required String quizId,
    required List<AnswerModel> answers,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _quizRepository.submitQuiz(
        quizId: quizId,
        answers: answers,
      );
      state = state.copyWith(
        result: result,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear result
  void clearResult() {
    state = QuizSubmissionState();
  }
}

// Quiz Submission Provider
final quizSubmissionProvider =
    StateNotifierProvider<QuizSubmissionNotifier, QuizSubmissionState>((ref) {
  final quizRepository = ref.watch(quizRepositoryProvider);
  return QuizSubmissionNotifier(quizRepository);
});

// Single Quiz Provider
final quizProvider = FutureProvider.family<QuizModel, String>(
  (ref, quizId) async {
    final quizRepository = ref.watch(quizRepositoryProvider);
    return await quizRepository.getQuiz(quizId);
  },
);

// Story Quizzes Provider
final storyQuizzesProvider = FutureProvider.family<List<QuizModel>, String>(
  (ref, storyId) async {
    final quizRepository = ref.watch(quizRepositoryProvider);
    return await quizRepository.getQuizzesByStory(storyId);
  },
);
