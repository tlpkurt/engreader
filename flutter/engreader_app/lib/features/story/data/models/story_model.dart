import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_model.freezed.dart';
part 'story_model.g.dart';

@freezed
class StoryModel with _$StoryModel {
  const StoryModel._();
  
  const factory StoryModel({
    required String id,
    String? userId,  // Optional, backend doesn't always send it
    required String title,
    String? content,  // Optional - not in list view
    @JsonKey(name: 'level') required String cefrLevel,  // Backend sends "level" as string (A1, A2, etc.)
    required int wordCount,
    @JsonKey(defaultValue: []) List<String>? targetWords,  // Optional - not in list view
    String? topic,
    @JsonKey(name: 'status') String? status,  // Backend status as string enum
    bool? isCompleted,
    int? readingTimeSeconds,
    @JsonKey(name: 'readingTimeMinutes') int? readingTimeMinutes,  // Backend uses minutes
    DateTime? completedAt,
    DateTime? createdAt,
    QuizData? quiz,  // Quiz included with story
  }) = _StoryModel;

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);
  
  /// CEFR level is already a string, just return it
  String get cefrLevelString => cefrLevel;
}

@freezed
class StoryGenerationRequest with _$StoryGenerationRequest {
  const factory StoryGenerationRequest({
    required String cefrLevel,
    required String topic,
    required List<String> targetWords,
    required int wordCount,
  }) = _StoryGenerationRequest;

  factory StoryGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$StoryGenerationRequestFromJson(json);

  Map<String, dynamic> toJson() => {
        'cefrLevel': cefrLevel,
        'topic': topic,
        'targetWords': targetWords,
        'wordCount': wordCount,
      };
}

@freezed
class QuizData with _$QuizData {
  const factory QuizData({
    required String id,
    required String storyId,
    String? title,
    required List<QuizQuestionData> questions,
  }) = _QuizData;

  factory QuizData.fromJson(Map<String, dynamic> json) =>
      _$QuizDataFromJson(json);
}

@freezed
class QuizQuestionData with _$QuizQuestionData {
  const factory QuizQuestionData({
    required String id,
    @JsonKey(name: 'questionNumber') required int questionNumber,
    @JsonKey(name: 'questionText') required String question,
    @JsonKey(name: 'optionA') required String optionA,
    @JsonKey(name: 'optionB') required String optionB,
    @JsonKey(name: 'optionC') required String optionC,
    @JsonKey(name: 'optionD') required String optionD,
  }) = _QuizQuestionData;

  factory QuizQuestionData.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionDataFromJson(json);
}

