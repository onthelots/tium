import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/services/hive/hive_prefs.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/domain/usecases/onboarding/onboarding_usecase.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingQuestions getQuestions;

  OnboardingBloc(this.getQuestions) : super(OnboardingInitial()) {
    // 1) 질문 로딩 -----------------------------------------
    on<LoadOnboardingQuestions>((event, emit) async {
      emit(OnboardingLoading());
      try {
        final questions = await getQuestions();
        emit(OnboardingLoaded(questions));
      } catch (e) {
        emit(OnboardingError(e.toString()));
      }
    });

    // 2) 답변 저장 ------------------------------------------
    on<SaveOnboardingAnswers>((event, emit) async {
      try {
        // Map -> UserModel 변환
        final user = UserModel(
          environment: event.answers['environment'] as String,
          interests: List<String>.from(event.answers['interests'] as List),
          experience: event.answers['experience'] as String,
          indoorPlants: const [],   // 최초엔 식물 없음
          outdoorPlants: const [],
        );

        await UserPrefs.saveUser(user);  // Hive box 'userBox'에 저장
        emit(OnboardingSaved());
      } catch (e) {
        emit(OnboardingError(e.toString()));
      }
    });
  }
}