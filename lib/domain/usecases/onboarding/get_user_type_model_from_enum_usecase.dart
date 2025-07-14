import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/data/models/user/user_type_model.dart';
import 'package:tium/domain/repositories/onboarding/onboarding_repository.dart';

/// 유저타입 상세정보 불러오기 (server)
class GetUserTypeModelFromEnumUseCase {
  final OnboardingRepository repository;

  GetUserTypeModelFromEnumUseCase(this.repository);

  Future<UserTypeModel> call(UserType userType) {
    return repository.getUserTypeModelByEnum(userType);
  }
}
