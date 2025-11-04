import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/translation_model.dart';

class TranslationRemoteDataSource {
  final ApiClient _apiClient;

  TranslationRemoteDataSource(this._apiClient);

  /// Translate text
  Future<TranslationModel> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? storyId,
    required bool isWord,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.translationsEndpoint,
        data: {
          'sourceText': text,
          'isWord': isWord,
          'sourceLanguage': sourceLanguage,
          'targetLanguage': targetLanguage,
          if (storyId != null) 'storyId': storyId,
        },
      );
      // Backend returns ApiResponse wrapper, extract data
      return TranslationModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Get cached translation
  Future<TranslationModel?> getCachedTranslation({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConfig.translationsEndpoint,
        queryParameters: {
          'text': text,
          'sourceLanguage': sourceLanguage,
          'targetLanguage': targetLanguage,
        },
      );

      // Backend returns ApiResponse wrapper, extract data
      if (response.data != null && response.data['data'] != null) {
        return TranslationModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null; // Return null if not found in cache
    }
  }
}
