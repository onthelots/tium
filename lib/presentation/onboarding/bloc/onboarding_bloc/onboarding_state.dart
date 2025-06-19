import 'package:tium/domain/entities/onboarding/onboarding_question_entity.dart';

abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingLoaded extends OnboardingState {
  final List<OnboardingQuestion> questions;
  OnboardingLoaded(this.questions);
}

class OnboardingSaved extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;
  OnboardingError(this.message);
}