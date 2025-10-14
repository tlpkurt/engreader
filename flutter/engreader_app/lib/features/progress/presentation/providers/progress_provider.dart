import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/progress_model.dart';
import '../../data/datasources/progress_remote_datasource.dart';
import '../../data/repositories/progress_repository.dart';
import '../../../../core/network/api_client.dart';

// Progress Remote DataSource Provider
final progressRemoteDataSourceProvider =
    Provider<ProgressRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProgressRemoteDataSource(apiClient);
});

// Progress Repository Provider
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final remoteDataSource = ref.watch(progressRemoteDataSourceProvider);
  return ProgressRepository(remoteDataSource);
});

// Progress Provider
final progressProvider = FutureProvider<ProgressModel>((ref) async {
  final progressRepository = ref.watch(progressRepositoryProvider);
  return await progressRepository.getProgress();
});

// Progress Event Notifier
class ProgressEventNotifier extends StateNotifier<AsyncValue<void>> {
  final ProgressRepository _progressRepository;
  final Ref _ref;

  ProgressEventNotifier(this._progressRepository, this._ref)
      : super(const AsyncValue.data(null));

  /// Track a progress event
  Future<void> trackEvent({
    required String eventType,
    required Map<String, dynamic> eventData,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _progressRepository.trackEvent(
        eventType: eventType,
        eventData: eventData,
      );
      // Invalidate progress to refresh
      _ref.invalidate(progressProvider);
    });
  }
}

// Progress Event Provider
final progressEventProvider =
    StateNotifierProvider<ProgressEventNotifier, AsyncValue<void>>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  return ProgressEventNotifier(progressRepository, ref);
});
