import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/adaptive_alert.dart';
import 'package:tium/components/custom_loading_indicator.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/core/di/locator.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/core/services/shared_preferences_helper.dart';
import 'package:tium/domain/entities/onboarding/onboarding_question_entity.dart';
import 'package:tium/presentation/onboarding/bloc/onboarding_bloc/onboarding_bloc.dart';
import 'package:tium/presentation/onboarding/bloc/onboarding_bloc/onboarding_event.dart';
import 'package:tium/presentation/onboarding/bloc/onboarding_bloc/onboarding_state.dart';

class OnboardingScreen extends StatelessWidget {
  final bool isHomePushed;

  const OnboardingScreen({super.key, required this.isHomePushed});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => locator<OnboardingBloc>()..add(LoadOnboardingQuestions()), child: OnboardingView(isHomePushed: isHomePushed,));
  }
}

class OnboardingView extends StatefulWidget {
  final bool isHomePushed;
  const OnboardingView({super.key, required this.isHomePushed});
  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  String experienceLevel = '';
  String locationPreference = '';
  String careTime = '';
  List<String> interestTags = [];

  int get currentPage => (_pageController.hasClients ? _pageController.page?.round() : 0) ?? 0;
  final int totalPages = 4;

  void _nextPage() {
    if (currentPage < totalPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      context.read<OnboardingBloc>().add(SaveOnboardingAnswers({
        'experience_level': experienceLevel,
        'location_preference': locationPreference,
        'care_time': careTime,
        'interest_tags': interestTags,
      }));
    }
  }

  bool get isCurrentSelectionValid {
    switch (currentPage) {
      case 0:
        return experienceLevel.isNotEmpty;
      case 1:
        return locationPreference.isNotEmpty;
      case 2:
        return careTime.isNotEmpty;
      case 3:
        return interestTags.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _confirmSkip() async {
    final confirmed = await showAdaptiveAlert(
      context,
      title: '온보딩을 건너뛸까요?',
      content: '맞춤 추천과 식물 관리를 위해 간단한 설정이 필요해요!\n지금 그만두시면, 설정 화면에서 직접 등록해야 해요',
      defaultActionText: '건너뛰기',
      cancelActionText: '계속 설정하기',
    );
    if (confirmed == true) {
      await SharedPreferencesHelper.setFirstRunFalse();
      if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, Routes.main, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScaffold(
      appBarVisible: true,
      title: '맞춤 설정',
      leadingVisible: false,
      trailing: widget.isHomePushed ? null : TextButton(
          onPressed: () {
            _confirmSkip();
          },
          child: Text('건너뛰기', style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor, fontWeight: FontWeight.w300))),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(
          value: (currentPage + 1) / totalPages,
          color: theme.primaryColor,
          backgroundColor: theme.primaryColor.withOpacity(0.2),
          minHeight: 4,
        ),
      ),
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingSaved) {
            Navigator.pushNamedAndRemoveUntil(context, Routes.main, (_) => false);
          } else if (state is OnboardingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is OnboardingLoading) {
            return const CustomLoadingIndicator(size: 60);
          } else if (state is OnboardingLoaded) {
            return Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (_) => setState(() {}),
                    children: [
                      _buildVerticalOptions(
                        question: state.questions[0],
                        selectedList: experienceLevel.isEmpty ? [] : [experienceLevel],
                        isMulti: false,
                        onChanged: (list) => setState(() => experienceLevel = list.isNotEmpty ? list.first : ''),
                      ),
                      _buildVerticalOptions(
                        question: state.questions[1],
                        selectedList: locationPreference.isEmpty ? [] : [locationPreference],
                        isMulti: false,
                        onChanged: (list) => setState(() => locationPreference = list.isNotEmpty ? list.first : ''),
                      ),
                      _buildVerticalOptions(
                        question: state.questions[2],
                        selectedList: careTime.isEmpty ? [] : [careTime],
                        isMulti: false,
                        onChanged: (list) => setState(() => careTime = list.isNotEmpty ? list.first : ''),
                      ),
                      _buildVerticalOptions(
                        question: state.questions[3],
                        selectedList: interestTags,
                        isMulti: true,
                        onChanged: (list) => setState(() => interestTags = list),
                      ),
                    ],
                  ),
                ),
                NextButton(isLastPage: currentPage == totalPages - 1, onPressed: _nextPage, enabled: isCurrentSelectionValid),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildVerticalOptions({
    required OnboardingQuestion question,
    required List<String> selectedList,
    required bool isMulti,
    required Function(List<String>) onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ─── 질문 텍스트 ───────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            question.questionText.replaceAll(r'\n', '\n'), // 줄바꿈 텍스트 처리
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ─── 옵션 리스트 ──────────────────────
        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: question.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final option = question.options[index];
              final selected = selectedList.contains(option);

              final iconData = [
                Icons.water_drop_outlined,
                Icons.house_outlined,
                Icons.local_florist_outlined,
              ][index % 3];

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final newSelected = List<String>.from(selectedList);
                  if (isMulti) {
                    selected ? newSelected.remove(option) : newSelected.add(
                        option);
                  } else {
                    newSelected
                      ..clear()
                      ..add(option);
                  }
                  onChanged(newSelected);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected ? theme.primaryColor : theme
                          .disabledColor,
                      width: 1,
                    ),
                    color: selected
                        ? theme.focusColor.withOpacity(0.1)
                        : theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iconData,
                        size: 36,
                        color: selected ? theme.primaryColor : theme
                            .disabledColor,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          option,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: selected ? theme.primaryColor : theme
                                .hintColor,
                            fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 다음 버튼
class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLastPage;
  final bool enabled;

  const NextButton({
    super.key,
    required this.onPressed,
    this.isLastPage = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? theme.primaryColor : theme.disabledColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: enabled ? 4 : 0,
        ),
        onPressed: enabled ? onPressed : null,  // 여기서 onPressed를 null로 설정,
        child: Text(
          isLastPage ? '완료' : '다음',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
