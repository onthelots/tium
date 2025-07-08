
import 'package:tium/data/models/onboarding/onboarding_question_model.dart';
import 'package:tium/data/models/user/user_type_model.dart';
import 'package:tium/data/models/user/user_model.dart'; // UserType Enum을 위해 임포트

abstract class OnboardingRepository {
  Future<List<OnboardingQuestionModel>> getOnboardingQuestions();
  Future<UserTypeModel> determineUserType(List<int> answerIds);
  Future<UserTypeModel> getUserTypeModelByEnum(UserType userType);
}
