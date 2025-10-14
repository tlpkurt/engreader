import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_model.freezed.dart';
part 'translation_model.g.dart';

@freezed
class TranslationModel with _$TranslationModel {
  const factory TranslationModel({
    required String id,
    required String userId,
    required String text,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    String? storyId,
    DateTime? createdAt,
  }) = _TranslationModel;

  factory TranslationModel.fromJson(Map<String, dynamic> json) =>
      _$TranslationModelFromJson(json);
}
