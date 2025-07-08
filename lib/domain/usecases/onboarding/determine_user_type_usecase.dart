import 'package:tium/data/models/user/user_type_model.dart';
import 'package:tium/domain/repositories/onboarding/onboarding_repository.dart';

class DetermineUserTypeUseCase {
  final OnboardingRepository repository;

  DetermineUserTypeUseCase(this.repository);

  Future<UserTypeModel> call(List<int> answerIds) {
    return repository.determineUserType(answerIds);
  }
}
