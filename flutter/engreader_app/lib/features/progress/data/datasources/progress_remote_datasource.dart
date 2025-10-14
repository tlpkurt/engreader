import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/progress_model.dart';

class ProgressRemoteDataSource {
  final ApiClient _apiClient;

  ProgressRemoteDataSource(this._apiClient);

  /// Get user progress
  Future<ProgressModel> getProgress() async {
    try {
      final response = await _apiClient.get(
        AppConfig.progressEndpoint,
      );
      // Backend returns ApiResponse wrapper, extract data
      return ProgressModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Track progress event
  Future<void> trackEvent({
    required String eventType,
    required Map<String, dynamic> eventData,
  }) async {
    try {
      await _apiClient.post(
        '${AppConfig.progressEndpoint}/track',
        data: {
          'eventType': eventType,
          'eventData': eventData,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
