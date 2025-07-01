import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/onboarding/bloc/recommendation/recommend_plant_bloc.dart';
import 'package:tium/presentation/onboarding/bloc/recommendation/recommend_plant_event.dart';
import 'package:tium/presentation/onboarding/utils/user_type_info.dart';

class OnboardingResultScreen extends StatefulWidget {
  final bool isFirstRun;
  final UserType userType;

  const OnboardingResultScreen({
    super.key,
    required this.userType,
    required this.isFirstRun,
  });

  @override
  State<OnboardingResultScreen> createState() => _OnboardingResultScreenState();
}

class _OnboardingResultScreenState extends State<OnboardingResultScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.read<RecommendationBloc>().add(
        LoadUserRecommendations(userType: widget.userType),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = userTypeInfo[widget.userType]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.dividerColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text('내 식물 케어 유형', style: theme.textTheme.labelLarge,),
      ),
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
                    info.imageAsset,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // 유저 타입 제목
              Text(
                info.title,
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
                      info.description,
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
      bottomNavigationBar: !widget.isFirstRun ? null : Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30), // 하단만 여백
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 0),
          child: SizedBox(
            width: double.infinity,
            height: 52, // 더 얇게
            child: ElevatedButton(
              onPressed: () {
                if (widget.isFirstRun) {
                  Navigator.pushNamedAndRemoveUntil(
                    context, Routes.main, (route) => false,
                  );
                } else {
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
        ),
      ),
    );
  }
}


/// 추천 식물리스트 (좀 필터링을 줄이자)
/*
// 추천 식물 리스트
              BlocBuilder<RecommendationBloc, RecommendationState>(
                builder: (context, state) {
                  if (state is RecommendationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RecommendationLoaded) {
                    if (state.plants.isEmpty) {
                      return Text(
                        "추천 식물이 없습니다.",
                        style: theme.textTheme.bodyMedium,
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.plants.length,
                      separatorBuilder: (_, __) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final plant = state.plants[index];
                        final imageUrl = plant.highResImageUrl ?? plant.imageUrl;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: buildCachedImage(imageUrl),
                          ),
                          title: Text(
                            plant.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.plantDetail,
                              arguments: {
                                'id': plant.id,
                                'category': plant.category,
                                'imageUrl': imageUrl,
                                'name': plant.name,
                              },
                            );
                          },
                        );
                      },
                    );
                  } else if (state is RecommendationError) {
                    return Text(
                      '추천 실패: ${state.message}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
 */