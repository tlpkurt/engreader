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
    @JsonKey(name: 'level') required int cefrLevel,  // Backend sends "level" as int (0=A1, 1=A2, etc.)
    required int wordCount,
    @JsonKey(defaultValue: []) List<String>? targetWords,  // Optional - not in list view
    String? topic,
    @JsonKey(name: 'status') int? status,  // Backend status (0=Pending, 1=Generating, 2=Generated, 3=Failed)
    bool? isCompleted,
    int? readingTimeSeconds,
    @JsonKey(name: 'readingTimeMinutes') int? readingTimeMinutes,  // Backend uses minutes
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _StoryModel;

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);
  
  /// Convert CEFR level int to string (0=A1, 1=A2, 2=B1, 3=B2, 4=C1, 5=C2)
  String get cefrLevelString {
    const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    if (cefrLevel >= 0 && cefrLevel < levels.length) {
      return levels[cefrLevel];
    }
    return 'A1'; // Default
  }
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
