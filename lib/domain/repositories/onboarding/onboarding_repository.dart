import 'package:tium/domain/entities/onboarding/onboarding_question_entity.dart';

abstract class OnboardingRepository {
  Future<List<OnboardingQuestion>> getQuestions();
}