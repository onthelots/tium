import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/constants/constants.dart';
import 'package:tium/core/services/hive/hive_prefs.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/core/services/shared_preferences_helper.dart';
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
        final experienceText = event.answers['experience_level'] as String;
        final locationText = event.answers['location_preference'] as String;
        final careText = event.answers['care_time'] as String;
        final interestText = event.answers['interest_tags'] as String;

        final experience = experienceMap[experienceText] ?? 'beginner';
        final location = locationMap[locationText] ?? 'anywhere';
        final care = careTimeMap[careText] ?? 'moderate';
        final interest = interestMap[interestText] ?? 'shape';

        final userType = determineUserType(
          experienceLevel: experience,
          locationPreference: location,
          careTime: care,
          interestTags: interest,
        );

        final user = UserModel(
          experienceLevel: experience,
          locationPreference: location,
          careTime: care,
          interestTags: interest, // 이제 단일 선택이므로
          userType: userType,
          indoorPlants: const [],
          outdoorPlants: const [],
        );

        await UserPrefs.saveUser(user);
        emit(OnboardingSaved(userType));
      } catch (e) {
        emit(OnboardingError(e.toString()));
      }
    });
  }
}

// user type 설정
UserType determineUserType({
  required String experienceLevel,
  required String locationPreference,
  required String careTime,
  required String interestTags,
}) {
  if (experienceLevel == 'beginner') {
    if (locationPreference == 'window' && careTime == 'short' && interestTags == 'flower') {
      return UserType.sunnyLover;
    } else if (locationPreference == 'bedroom' && careTime == 'short') {
      return UserType.quietCompanion;
    } else {
      return UserType.smartSaver;
    }
  }

  if (experienceLevel == 'intermediate') {
    if (interestTags == 'flower') return UserType.bloomingWatcher;
    if (interestTags == 'shape') return UserType.growthSeeker;
    return UserType.seasonalRomantic;
  }

  if (experienceLevel == 'expert') {
    if (careTime == 'plenty' && locationPreference == 'window') {
      return UserType.plantMaster;
    } else if (interestTags == 'price') {
      return UserType.calmObserver;
    } else {
      return UserType.growthExplorer;
    }
  }

  // fallback
  return UserType.smartSaver;
}