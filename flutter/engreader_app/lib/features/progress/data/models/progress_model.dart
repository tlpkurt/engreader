import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_model.freezed.dart';
part 'progress_model.g.dart';

@freezed
class ProgressModel with _$ProgressModel {
  const factory ProgressModel({
    required String userId,
    String? currentCefrLevel,
    @Default(0) int totalStoriesRead,
    @Default(0) int totalQuizzesTaken,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0.0) double averageQuizScore,
    DateTime? lastActivityDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProgressModel;

  factory ProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressModelFromJson(json);
}

@freezed
class ProgressEventModel with _$ProgressEventModel {
  const factory ProgressEventModel({
    required String eventType,
    required Map<String, dynamic> eventData,
  }) = _ProgressEventModel;

  factory ProgressEventModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressEventModelFromJson(json);

  Map<String, dynamic> toJson() => {
        'eventType': eventType,
        'eventData': eventData,
      };
}
