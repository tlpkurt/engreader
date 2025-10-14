import '../datasources/translation_remote_datasource.dart';
import '../models/translation_model.dart';

class TranslationRepository {
  final TranslationRemoteDataSource _remoteDataSource;

  TranslationRepository(this._remoteDataSource);

  /// Translate text with caching
  Future<TranslationModel> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? storyId,
  }) async {
    // Try to get from cache first
    final cached = await _remoteDataSource.getCachedTranslation(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    if (cached != null) {
      return cached;
    }

    // If not in cache, fetch new translation
    return await _remoteDataSource.translate(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      storyId: storyId,
    );
  }
}
