import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/di/locator.dart';
import 'package:tium/presentation/onboarding/bloc/onboarding_bloc/onboarding_bloc.dart';
import 'package:tium/presentation/onboarding/bloc/onboarding_bloc/onboarding_event.dart';
import 'package:tium/presentation/onboarding/bloc/onboarding_bloc/onboarding_state.dart';

// onboarding_pages.dart
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<OnboardingBloc>()..add(LoadOnboardingQuestions()),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  // temp answer cache
  String env = '';
  List<String> interests = [];
  String exp = '';

  void _nextPage() {
    if (_pageController.page! < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // save via Bloc
      context.read<OnboardingBloc>().add(SaveOnboardingAnswers({
        'environment': env,
        'interests': interests,
        'experience': exp,
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingSaved) {
            Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
          }
          if (state is OnboardingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is OnboardingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OnboardingLoaded) {
            return Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildOptionPage(
                        title: state.questions[1].questionText,
                        options: state.questions[1].options,
                        selectedOption: env,
                        onSelected: (v) => setState(() => env = v),
                      ),
                      _buildMultiSelectPage(
                        title: state.questions[3].questionText,
                        options: state.questions[3].options,
                        selectedOptions: interests,
                        onChanged: (vals) => setState(() => interests = vals),
                      ),
                      _buildOptionPage(
                        title: state.questions[0].questionText,
                        options: state.questions[0].options,
                        selectedOption: exp,
                        onSelected: (v) => setState(() => exp = v),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(onPressed: _nextPage, child: const Text('다음')),
                )
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Helper UI builders
  Widget _buildOptionPage({required String title, required List<String> options, required String selectedOption, required Function(String) onSelected}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        ...options.map((o) => RadioListTile(value: o, groupValue: selectedOption, title: Text(o), onChanged: (val) => onSelected(val!))),
      ],
    );
  }

  Widget _buildMultiSelectPage({required String title, required List<String> options, required List<String> selectedOptions, required Function(List<String>) onChanged}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        ...options.map((o) => CheckboxListTile(
          value: selectedOptions.contains(o),
          title: Text(o),
          onChanged: (checked) {
            final list = List<String>.from(selectedOptions);
            checked! ? list.add(o) : list.remove(o);
            onChanged(list);
          },
        )),
      ],
    );
  }
}