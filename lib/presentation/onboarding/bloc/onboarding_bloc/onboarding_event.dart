abstract class OnboardingEvent {}

// 온보딩 데이터 불러오기
class LoadOnboardingQuestions extends OnboardingEvent {}

// 온보딩 답변 저장하기
class SaveOnboardingAnswers extends OnboardingEvent {
  final Map<String, dynamic> answers;
  SaveOnboardingAnswers(this.answers);
}