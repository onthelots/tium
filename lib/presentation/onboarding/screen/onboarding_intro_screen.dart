import 'package:flutter/material.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/core/constants/constants.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/core/services/shared_preferences_helper.dart';

class OnboardingIntroScreen extends StatelessWidget {
  const OnboardingIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScaffold(
      title: null,
      appBarVisible: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          Icon(Icons.eco_outlined, size: 80, color: Colors.green.shade700),

          const SizedBox(height: 24),

          // > title
          Text(
            '나에게 꼭 맞는 식물 관리,\n시작해 보시겠어요?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // > subtitle
          Text(
            '내 공간과 라이프스타일을 알려주시면\n더 편리한 식물 관리 경험을 드려요.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // > 맞춤관리 시작 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: () async {
                await SharedPreferencesHelper.setFirstRunFalse();
                Navigator.pushReplacementNamed(context, Routes.onboarding, arguments: false);
              },
              child: Text(
                  '맞춤 관리 시작하기',
                  style: theme.textTheme.titleMedium?.copyWith(color: AppColors.lightBackground)
              ),
            ),
          ),

          const SizedBox(height: 10),

          // > 나중에 하기
          TextButton(
            onPressed: () async {
              await SharedPreferencesHelper.setFirstRunFalse();
              Navigator.pushReplacementNamed(context, Routes.main);
            },
            child: Text(
                '나중에 할게요',
                style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.disabledColor)
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
