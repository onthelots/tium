import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/data/models/onboarding/onboarding_question_model.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/domain/usecases/onboarding/determine_user_type_usecase.dart';
import 'package:tium/domain/usecases/onboarding/get_onboarding_questions_usecase.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingQuestionsUseCase getQuestionsUseCase;
  final DetermineUserTypeUseCase determineUserTypeUseCase;

  List<OnboardingQuestionModel> _questions = []; // 질문 목록을 저장할 변수

  OnboardingBloc({
    required this.getQuestionsUseCase,
    required this.determineUserTypeUseCase,
  }) : super(OnboardingInitial()) {
    on<LoadOnboardingQuestions>((event, emit) async {
      emit(OnboardingLoading());
      try {
        _questions = await getQuestionsUseCase(); // 질문 로드 후 저장
        emit(OnboardingLoaded(_questions));
      } catch (e) {
        emit(OnboardingError(e.toString()));
      }
    });

    // 유저타입 저장 -> HIVE (UserType / enum 타입)
    on<SaveOnboardingAnswers>((event, emit) async {
      try {
        // 1. 서버로 답변 ID들을 보내 사용자 유형 결정 요청
        final answerIds = event.answers.values.cast<int>().toList();
        final userTypeModel = await determineUserTypeUseCase(answerIds);

        // 2. UserModel에 저장할 문자열 값 찾기
        String getAnswerTextById(int answerId) {
          for (var question in _questions) {
            for (var answer in question.answers) {
              if (answer.id == answerId) {
                return answer.answerText;
              }
            }
          }
          return ''; // 찾지 못하면 빈 문자열 반환 (오류 방지)
        }

        // 기존 사용자 정보 불러오기
        final existingUser = await UserPrefs.getUser();

        final updatedUser = (existingUser ?? UserModel(
          experienceLevel: '',
          locationPreference: '',
          careTime: '',
          interestTags: '',
          userType: UserType.sunnyLover, // 기본값, 실제로는 아래에서 덮어씀
        )).copyWith(
          experienceLevel: getAnswerTextById(event.answers['experience_level'] as int),
          locationPreference: getAnswerTextById(event.answers['location_preference'] as int),
          careTime: getAnswerTextById(event.answers['care_time'] as int),
          interestTags: getAnswerTextById(event.answers['interest_tags'] as int),
          userType: userTypeModel.toEnum(),
        );

        await UserPrefs.saveUser(updatedUser); // HIVE 저장
        emit(OnboardingSaved(userTypeModel)); // 저장 시, Server에서 상세 내용 받아오고, 저장하기
      } catch (e) {
        emit(OnboardingError(e.toString()));
      }
    });
  }
}
