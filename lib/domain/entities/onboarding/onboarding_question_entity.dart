class OnboardingQuestion {
  final String key;
  final String questionText;
  final List<String> options;
  final String type;
  final int order;
  final bool isActive;

  const OnboardingQuestion({
    required this.key,
    required this.questionText,
    required this.options,
    required this.type,
    required this.order,
    required this.isActive,
  });
}
