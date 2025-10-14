import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

@freezed
class QuizModel with _$QuizModel {
  const factory QuizModel({
    required String id,
    required String storyId,
    required String userId,
    required List<QuizQuestionModel> questions,
    int? score,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _QuizModel;

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);
}

@freezed
class QuizQuestionModel with _$QuizQuestionModel {
  const factory QuizQuestionModel({
    required String id,
    required String question,
    required List<String> options,
    required int correctAnswerIndex,
    String? explanation,
    int? userAnswerIndex,
  }) = _QuizQuestionModel;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionModelFromJson(json);
}

@freezed
class QuizSubmissionModel with _$QuizSubmissionModel {
  const factory QuizSubmissionModel({
    required List<AnswerModel> answers,
  }) = _QuizSubmissionModel;

  factory QuizSubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizSubmissionModelFromJson(json);

  Map<String, dynamic> toJson() => {
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}

@freezed
class AnswerModel with _$AnswerModel {
  const factory AnswerModel({
    required String questionId,
    required int answerIndex,
  }) = _AnswerModel;

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'answerIndex': answerIndex,
      };
}

@freezed
class QuizResultModel with _$QuizResultModel {
  const factory QuizResultModel({
    required int score,
    required int totalQuestions,
    required List<QuizQuestionModel> questions,
  }) = _QuizResultModel;

  factory QuizResultModel.fromJson(Map<String, dynamic> json) =>
      _$QuizResultModelFromJson(json);
}
