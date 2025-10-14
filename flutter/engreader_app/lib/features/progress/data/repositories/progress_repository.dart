import '../datasources/progress_remote_datasource.dart';
import '../models/progress_model.dart';

class ProgressRepository {
  final ProgressRemoteDataSource _remoteDataSource;

  ProgressRepository(this._remoteDataSource);

  /// Get user progress
  Future<ProgressModel> getProgress() async {
    return await _remoteDataSource.getProgress();
  }

  /// Track a progress event
  Future<void> trackEvent({
    required String eventType,
    required Map<String, dynamic> eventData,
  }) async {
    await _remoteDataSource.trackEvent(
      eventType: eventType,
      eventData: eventData,
    );
  }
}
