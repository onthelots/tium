
import 'package:tium/data/models/onboarding/onboarding_question_model.dart';
import 'package:tium/data/models/user/user_type_model.dart';

abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingLoaded extends OnboardingState {
  final List<OnboardingQuestionModel> questions;
  OnboardingLoaded(this.questions);
}

class OnboardingSaved extends OnboardingState {
  final UserTypeModel userTypeModel;
  OnboardingSaved(this.userTypeModel);
}

class OnboardingError extends OnboardingState {
  final String message;
  OnboardingError(this.message);
}
