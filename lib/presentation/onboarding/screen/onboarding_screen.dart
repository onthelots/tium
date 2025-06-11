import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/core/services/shared_preferences_helper.dart';

class OnboardingPrefs {
  static const String keyEnv = 'onboarding_env';
  static const String keyInterests = 'onboarding_interests';
  static const String keyExperience = 'onboarding_experience';

  static Future<void> saveOnboardingData({
    required String environment,
    required List<String> interests,
    required String experience,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyEnv, environment);
    await prefs.setStringList(keyInterests, interests);
    await prefs.setString(keyExperience, experience);
  }

  static Future<Map<String, dynamic>> loadOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'environment': prefs.getString(keyEnv) ?? '',
      'interests': prefs.getStringList(keyInterests) ?? [],
      'experience': prefs.getString(keyExperience) ?? '',
    };
  }
}

// onboarding_pages.dart
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  String selectedEnv = '';
  List<String> selectedInterests = [];
  String selectedExperience = '';

  void _nextPage() {
    if (_pageController.page! < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      SharedPreferencesHelper.setFirstRunStateToFalse();
      OnboardingPrefs.saveOnboardingData(
        environment: selectedEnv,
        interests: selectedInterests,
        experience: selectedExperience,
      );
      Navigator.pushNamedAndRemoveUntil(context, Routes.main, (_) => false);
    }
  }

  Widget _buildEnvironmentPage() {
    final options = ['실내', '야외', '둘 다', '잘 모르겠어요'];
    return _buildOptionPage(
      title: '어디에서 식물을 키우시나요?',
      options: options,
      selectedOption: selectedEnv,
      onSelected: (val) => setState(() => selectedEnv = val),
    );
  }

  Widget _buildInterestPage() {
    final options = ['상추', '고추', '토마토', '허브', '몬스테라', '스투키'];
    return _buildMultiSelectPage(
      title: '관심 있는 작물을 골라주세요',
      options: options,
      selectedOptions: selectedInterests,
      onChanged: (val) => setState(() => selectedInterests = val),
    );
  }

  Widget _buildExperiencePage() {
    final options = ['처음이에요', '조금 해봤어요', '꽤 자신 있어요'];
    return _buildOptionPage(
      title: '식물 키우기 경험은?',
      options: options,
      selectedOption: selectedExperience,
      onSelected: (val) => setState(() => selectedExperience = val),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEnvironmentPage(),
                _buildInterestPage(),
                _buildExperiencePage(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _nextPage,
              child: const Text('다음'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOptionPage({
    required String title,
    required List<String> options,
    required String selectedOption,
    required Function(String) onSelected,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        ...options.map((option) => RadioListTile(
          title: Text(option),
          value: option,
          groupValue: selectedOption,
          onChanged: (val) => onSelected(val!),
        )),
      ],
    );
  }

  Widget _buildMultiSelectPage({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        ...options.map((option) => CheckboxListTile(
          title: Text(option),
          value: selectedOptions.contains(option),
          onChanged: (bool? checked) {
            final newList = List<String>.from(selectedOptions);
            checked! ? newList.add(option) : newList.remove(option);
            onChanged(newList);
          },
        )),
      ],
    );
  }
}