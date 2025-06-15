import 'package:tium/domain/entities/onboarding/onboarding_question.dart';
import 'package:tium/domain/repositories/onboarding/onboarding_repository.dart';

class GetOnboardingQuestions {
  final OnboardingRepository repository;

  GetOnboardingQuestions(this.repository);

  Future<List<OnboardingQuestion>> call() {
    return repository.getQuestions();
  }
}