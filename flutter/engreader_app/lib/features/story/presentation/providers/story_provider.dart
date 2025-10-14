import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/story_model.dart';
import '../../data/datasources/story_remote_datasource.dart';
import '../../data/repositories/story_repository.dart';
import '../../../../core/network/api_client.dart';

// Story Remote DataSource Provider
final storyRemoteDataSourceProvider = Provider<StoryRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StoryRemoteDataSource(apiClient);
});

// Story Repository Provider
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  final remoteDataSource = ref.watch(storyRemoteDataSourceProvider);
  return StoryRepository(remoteDataSource);
});

// Story Generation State
class StoryGenerationState {
  final StoryModel? story;
  final bool isLoading;
  final String? error;

  StoryGenerationState({
    this.story,
    this.isLoading = false,
    this.error,
  });

  StoryGenerationState copyWith({
    StoryModel? story,
    bool? isLoading,
    String? error,
  }) {
    return StoryGenerationState(
      story: story ?? this.story,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Story Generation Notifier
class StoryGenerationNotifier extends StateNotifier<StoryGenerationState> {
  final StoryRepository _storyRepository;

  StoryGenerationNotifier(this._storyRepository)
      : super(StoryGenerationState());

  /// Generate a new story
  Future<void> generateStory({
    required String cefrLevel,
    required String topic,
    required List<String> targetWords,
    required int wordCount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final story = await _storyRepository.generateStory(
        cefrLevel: cefrLevel,
        topic: topic,
        targetWords: targetWords,
        wordCount: wordCount,
      );
      state = state.copyWith(
        story: story,
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

  /// Clear generated story
  void clearStory() {
    state = StoryGenerationState();
  }
}

// Story Generation Provider
final storyGenerationProvider =
    StateNotifierProvider<StoryGenerationNotifier, StoryGenerationState>((ref) {
  final storyRepository = ref.watch(storyRepositoryProvider);
  return StoryGenerationNotifier(storyRepository);
});

// Story List Provider
final storyListProvider = FutureProvider.family<List<StoryModel>, Map<String, dynamic>?>(
  (ref, filters) async {
    final storyRepository = ref.watch(storyRepositoryProvider);
    return await storyRepository.getStories(
      cefrLevel: filters?['cefrLevel'],
      isCompleted: filters?['isCompleted'],
    );
  },
);

// Single Story Provider
final storyProvider = FutureProvider.family<StoryModel, String>(
  (ref, storyId) async {
    final storyRepository = ref.watch(storyRepositoryProvider);
    return await storyRepository.getStory(storyId);
  },
);

// Story Actions Notifier (for complete, delete)
class StoryActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final StoryRepository _storyRepository;
  final Ref _ref;

  StoryActionsNotifier(this._storyRepository, this._ref)
      : super(const AsyncValue.data(null));

  /// Complete a story
  Future<void> completeStory({
    required String storyId,
    required int readingTimeSeconds,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _storyRepository.completeStory(
        storyId: storyId,
        readingTimeSeconds: readingTimeSeconds,
      );
      // Invalidate story list to refresh
      _ref.invalidate(storyListProvider);
    });
  }

  /// Delete a story
  Future<void> deleteStory(String storyId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _storyRepository.deleteStory(storyId);
      // Invalidate story list to refresh
      _ref.invalidate(storyListProvider);
    });
  }
}

// Story Actions Provider
final storyActionsProvider =
    StateNotifierProvider<StoryActionsNotifier, AsyncValue<void>>((ref) {
  final storyRepository = ref.watch(storyRepositoryProvider);
  return StoryActionsNotifier(storyRepository, ref);
});
