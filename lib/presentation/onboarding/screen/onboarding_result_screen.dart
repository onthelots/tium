import 'package:flutter/material.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/user/user_type_model.dart';

class OnboardingResultScreen extends StatelessWidget {
  final bool isFirstRun;
  final UserTypeModel userType;

  const OnboardingResultScreen({
    super.key,
    required this.userType,
    required this.isFirstRun,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScaffold(
      appBarVisible: true,
      title: '내 식물 케어 유형',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 유저 타입 이미지
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    userType.imageAsset, // UserTypeModel에서 직접 가져옴
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // 유저 타입 제목
              Text(
                userType.typeName, // UserTypeModel에서 직접 가져옴
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 유저 타입 설명
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '당신의 케어 스타일은?',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userType.description, // UserTypeModel에서 직접 가져옴
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withOpacity(0.85),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), // 하단만 여백
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52, // 더 얇게
                child: ElevatedButton(
                  onPressed: () {

                    // 첫 구동일 경우
                    if (isFirstRun) {
                      Navigator.pushNamedAndRemoveUntil(
                        context, Routes.main, (route) => false,
                      );
                    } else {

                      // Home 혹은 MyPage에서 진입한 경우
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    '홈으로 이동하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),

              // Home 혹은 MyPage에서 진입한 경우
              if (!isFirstRun) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () async {
                      if (context.mounted) {

                        // 온보딩 재 진입
                        Navigator.pushNamed(
                          context, Routes.onboarding,
                          arguments: true, // 온보딩 화면으로 이동 시 isHomePushed 전달
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: theme.primaryColor), // 테두리 색상
                      foregroundColor: theme.primaryColor, // 텍스트 색상
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      '다시 설정하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}