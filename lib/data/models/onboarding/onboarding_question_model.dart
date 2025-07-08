import 'package:equatable/equatable.dart';

class OnboardingQuestionModel extends Equatable {
  final int id;
  final String questionText;
  final List<OnboardingAnswerModel> answers;

  const OnboardingQuestionModel({
    required this.id,
    required this.questionText,
    required this.answers,
  });

  factory OnboardingQuestionModel.fromJson(Map<String, dynamic> json) {
    var answerList = <OnboardingAnswerModel>[];
    if (json['onboarding_answers'] != null) {
      json['onboarding_answers'].forEach((v) {
        answerList.add(OnboardingAnswerModel.fromJson(v));
      });
    }

    return OnboardingQuestionModel(
      id: json['id'] as int,
      questionText: json['question_text'] as String,
      answers: answerList,
    );
  }

  @override
  List<Object?> get props => [id, questionText, answers];
}

class OnboardingAnswerModel extends Equatable {
  final int id;
  final String answerText;

  const OnboardingAnswerModel({
    required this.id,
    required this.answerText,
  });

  factory OnboardingAnswerModel.fromJson(Map<String, dynamic> json) {
    return OnboardingAnswerModel(
      id: json['id'] as int,
      answerText: json['answer_text'] as String,
    );
  }

  @override
  List<Object?> get props => [id, answerText];
}
