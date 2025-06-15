import 'package:tium/domain/entities/onboarding/onboarding_question.dart';

abstract class OnboardingRepository {
  Future<List<OnboardingQuestion>> getQuestions();
}