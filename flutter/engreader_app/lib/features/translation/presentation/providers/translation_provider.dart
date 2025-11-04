import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/translation_model.dart';
import '../../data/datasources/translation_remote_datasource.dart';
import '../../data/repositories/translation_repository.dart';
import '../../../../core/network/api_client.dart';

// Translation Remote DataSource Provider
final translationRemoteDataSourceProvider =
    Provider<TranslationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TranslationRemoteDataSource(apiClient);
});

// Translation Repository Provider
final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  final remoteDataSource = ref.watch(translationRemoteDataSourceProvider);
  return TranslationRepository(remoteDataSource);
});

// Translation State
class TranslationState {
  final TranslationModel? translation;
  final bool isLoading;
  final String? error;

  TranslationState({
    this.translation,
    this.isLoading = false,
    this.error,
  });

  TranslationState copyWith({
    TranslationModel? translation,
    bool? isLoading,
    String? error,
  }) {
    return TranslationState(
      translation: translation ?? this.translation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Translation Notifier
class TranslationNotifier extends StateNotifier<TranslationState> {
  final TranslationRepository _translationRepository;

  TranslationNotifier(this._translationRepository)
      : super(TranslationState());

  /// Translate text
  Future<void> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? storyId,
    required bool isWord,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final translation = await _translationRepository.translate(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        storyId: storyId,
        isWord: isWord,
      );
      state = state.copyWith(
        translation: translation,
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

  /// Clear translation
  void clearTranslation() {
    state = TranslationState();
  }
}

// Translation Provider
final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  final translationRepository = ref.watch(translationRepositoryProvider);
  return TranslationNotifier(translationRepository);
});
