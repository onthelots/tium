import 'package:tium/data/datasources/onboarding/onboarding_remote_data_source.dart';
import 'package:tium/data/models/onboarding/onboarding_question_model.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/data/models/user/user_type_model.dart';
import 'package:tium/domain/repositories/onboarding/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OnboardingQuestionModel>> getOnboardingQuestions() {
    return remoteDataSource.getOnboardingQuestions();
  }

  @override
  Future<UserTypeModel> determineUserType(List<int> answerIds) {
    return remoteDataSource.determineUserType(answerIds);
  }

  @override
  Future<UserTypeModel> getUserTypeModelByEnum(UserType userType) {
    return remoteDataSource.getUserTypeModelById(userType.index + 1); // Enum의 ID를 사용
  }
}
