import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/data/models/user/user_type_model.dart';
import 'package:tium/domain/repositories/onboarding/onboarding_repository.dart';

class GetUserTypeModelFromEnumUseCase {
  final OnboardingRepository repository;

  GetUserTypeModelFromEnumUseCase(this.repository);

  Future<UserTypeModel> call(UserType userType) {
    return repository.getUserTypeModelByEnum(userType);
  }
}
