import 'package:tium/data/models/onboarding/onboarding_question_model.dart';
import 'package:tium/domain/repositories/onboarding/onboarding_repository.dart';

/// 온보딩 질문 가져오기 (server)
class GetOnboardingQuestionsUseCase {
  final OnboardingRepository repository;

  GetOnboardingQuestionsUseCase(this.repository);

  Future<List<OnboardingQuestionModel>> call() {
    return repository.getOnboardingQuestions();
  }
}
