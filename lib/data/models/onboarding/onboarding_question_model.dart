import 'package:tium/domain/entities/onboarding/onboarding_question_entity.dart';

class OnboardingQuestionModel extends OnboardingQuestion {
  const OnboardingQuestionModel({
    required super.key,
    required super.questionText,
    required super.options,
    required super.type,
    required super.order,
    required super.isActive,
  });

  factory OnboardingQuestionModel.fromFirestore(Map<String, dynamic> json) {
    return OnboardingQuestionModel(
      key: json['key'] ?? '',
      questionText: json['question_text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      type: json['type'] ?? 'single_choice',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}