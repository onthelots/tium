import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_loading_indicator.dart';
import 'package:tium/core/constants/app_asset.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/home/bloc/recommendation/recommend_plant_bloc.dart';
import 'package:tium/presentation/home/bloc/recommendation/recommend_plant_event.dart';
import 'package:tium/presentation/home/bloc/recommendation/recommend_plant_state.dart';

class OnboardingResultScreen extends StatefulWidget {
  final UserType userType;

  const OnboardingResultScreen({super.key, required this.userType});

  @override
  State<OnboardingResultScreen> createState() => _OnboardingResultScreenState();
}

class _OnboardingResultScreenState extends State<OnboardingResultScreen> {
  bool _isGenerating = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isGenerating = false;
      });
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
        title: const Text('결과 분석'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isGenerating
          ? Center(child: CustomLoadingIndicator(message: "취향을 분석중입니다 ..."))
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 유저 타입 설명
              Image.asset(info.imageAsset, height: 200),
              const SizedBox(height: 32),
              Text(
                info.title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                info.description,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 추천 식물 섹션
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '당신에게 추천하는 식물 🌿',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              BlocBuilder<RecommendationBloc, RecommendationState>(
                builder: (context, state) {
                  if (state is RecommendationLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is RecommendationLoaded) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.plants.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final plant = state.plants[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              plant.imageUrl ?? '',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(plant.name),
                          subtitle: Text(plant.name ?? ''),
                        );
                      },
                    );
                  } else if (state is RecommendationError) {
                    return Text('추천 실패: ${state.message}');
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, Routes.main, (_) => false);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('홈으로 이동하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 예시 유저 타입 설명 정보
class UserTypeInfo {
  final String title;
  final String description;
  final String imageAsset;

  const UserTypeInfo({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}

final Map<UserType, UserTypeInfo> userTypeInfo = {
  UserType.sunnyLover: UserTypeInfo(
    title: '햇살을 사랑하는 당신',
    description: '창가에서 햇빛 가득한 식물과 함께하는 것을 좋아해요.',
    imageAsset: AppAsset.icon.icon_circle,
  ),
  UserType.quietCompanion: UserTypeInfo(
    title: '조용한 방의 동반자',
    description: '분주한 일상 속 조용한 방 안에서 식물과 함께해요.',
    imageAsset: AppAsset.icon.icon_circle,
  ),
  UserType.smartSaver: UserTypeInfo(
    title: '스마트하게 돌보는 사람',
    description: '부담 없는 관리로 식물과의 관계를 시작해요.',
    imageAsset: AppAsset.icon.icon_circle,
  ),
  UserType.bloomingWatcher: UserTypeInfo(
    title: '꽃을 기다리는 사람',
    description: '계절마다 피어나는 꽃을 보며 기쁨을 느껴요.',
    imageAsset: AppAsset.icon.icon_circle,
  ),
  UserType.growthSeeker: UserTypeInfo(
    title: '성장에 집중하는 사람',
    description: '잎과 줄기의 독특한 생김새에 매력을 느껴요.',
    imageAsset: AppAsset.icon.icon_circle,
  ),
  UserType.seasonalRomantic: UserTypeInfo(
    title: '계절을 타는 로맨티스트',
    description: '식물로 사계절을 느끼며 힐링하는 당신.',
    imageAsset: AppAsset.icon.icon_circle,
  ),
  UserType.plantMaster: UserTypeInfo(
    title: '식물 마스터',
    description: '매일 돌보며 식물과 깊은 교감을 나눠요.',
    imageAsset: AppAsset.icon.icon_circle,
  ),
  UserType.calmObserver: UserTypeInfo(
    title: '가성비를 중시하는 관찰자',
    description: '조용히, 알뜰하게 식물을 돌보는 당신.',
    imageAsset: AppAsset.icon.icon_circle,
  ),
  UserType.growthExplorer: UserTypeInfo(
    title: '성장을 탐험하는 사람',
    description: '식물의 변화와 가능성을 즐기는 도전가형!',
    imageAsset: AppAsset.icon.icon_circle,
  ),
};
