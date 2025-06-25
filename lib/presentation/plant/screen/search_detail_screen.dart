import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/di/locator.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_bloc.dart';
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_event.dart';
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_state.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantId;
  final PlantCategory category;
  final String imageUrl;
  final String name;

  const PlantDetailScreen({
    Key? key,
    required this.plantId,
    required this.category,
    required this.imageUrl,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) => locator<PlantDetailBloc>()
        ..add(PlantDetailRequested(
          id: plantId,
          category: category,
          name: name,
        )),
      child: Scaffold(
        body: BlocBuilder<PlantDetailBloc, PlantDetailState>(
          builder: (context, state) {
            if (state is PlantDetailLoading || state is PlantDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PlantDetailError) {
              return Center(child: Text(state.message));
            }

            if (state is PlantDetailLoaded) {
              final plant = state.plant;

              print("식물 이름 : ${plant.name}");

              return CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false, // ← 기본 백버튼 제거
                    pinned: true,
                    stretch: true,
                    stretchTriggerOffset: 100,
                    expandedHeight: 300,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    leading: null, // 기본 자동 생기지 않음

                    actions: [
                      Container(
                        margin: const EdgeInsets.only(top: 10, right: 15),
                        decoration: BoxDecoration(
                          color: theme.disabledColor,
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(5), // 아이콘 주변 여백 조절
                            child: Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],

                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.fadeTitle,
                      ],
                      titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                      title: Text(
                        plant.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black54,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      background: Hero(
                        tag: plant.id,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.broken_image,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              )
                            else
                              Container(color: Colors.grey[300]),
                            // 그라데이션 추가
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.65),
                                    Colors.black.withOpacity(0.35),
                                    Colors.black.withOpacity(0.15),
                                    Colors.black.withOpacity(0.05),
                                    Colors.black.withOpacity(0.4),
                                  ],
                                  stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                                  tileMode: TileMode.clamp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          '기본 정보',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 15),
                        // 기본 정보 박스
                        _HighlightInfoRow(
                          difficulty: difficultyLevelToString(plant.difficultyLevel),
                          watering: "${plant.wateringInfo.minDays}일 ~ ${plant.wateringInfo.maxDays}일",
                        ),

                        const SizedBox(height: 25),

                        Text(
                          '상세 정보',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 15),

                        // 상세 정보 박스
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoCard(label: '잘 자라는 온도 및 특징', value: parseHtmlBreaks(plant.growthInfo), icon: Icons.eco),
                            const SizedBox(height: 10),
                            _InfoCard(label: '키우는 방법', value: parseHtmlBreaks(plant.propagationMethod), icon: Icons.grass),
                            const SizedBox(height: 10),
                            _InfoCard(label: '빛을 어떻게, 얼마나 봐야해요?', value: mapSunlightInfo(plant.sunlightInfo), icon: Icons.wb_sunny),
                            const SizedBox(height: 10),
                            _InfoCard(label: '물은 얼마나 자주줘야 해요?', value: parseHtmlBreaks(plant.wateringInfo.description), icon: Icons.water_drop),
                            const SizedBox(height: 10),
                            _InfoCard(label: '얼마나 빨리 자라나요?', value: growthSpeedToString(plant.growthSpeed), icon: Icons.speed),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;

  const _InfoCard({
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(icon, color: theme.focusColor, size: 24),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.focusColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String parseHtmlBreaks(String? input) {
  if (input == null) return '';
  return input.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
}

String difficultyLevelToString(DifficultyLevel level) {
  switch (level) {
    case DifficultyLevel.beginner:
      return '초보자';
    case DifficultyLevel.intermediate:
      return '중급자';
    case DifficultyLevel.advanced:
      return '전문가';
    default:
      return '중급자';
  }
}

String mapSunlightInfo(String? sunlightInfo) {
  if (sunlightInfo == null || sunlightInfo.trim().isEmpty) return '광량 정보가 없습니다.';

  final normalized = sunlightInfo.replaceAll(RegExp(r'\s+'), ''); // 공백 제거
  // 각각 포함 여부 체크
  final hasLow = normalized.contains('낮은광도(300~800Lux)');
  final hasMid = normalized.contains('중간광도(800~1,500Lux)');
  final hasHigh = normalized.contains('높은광도(1,500~10,000Lux)');

  // 미리 정의한 조합에 따라 친숙한 문구 반환
  if (hasLow && hasMid && hasHigh) {
    return '어두운 곳부터 밝은 곳까지 모두 잘 자라요';
  }
  if (!hasLow && hasMid && hasHigh) {
    return '밝은 실내와 햇빛 좋은 곳에서 잘 자라요';
  }
  if (hasLow && hasMid && !hasHigh) {
    return '햋빛 상관없이 모든 환경에서 잘 자라요';
  }
  if (hasLow && !hasMid && hasHigh) {
    return '햋빛 상관없이 모든 환경에서 잘 자라요';
  }
  if (hasLow && !hasMid && !hasHigh) {
    return '어두운 실내에서도 잘 자라요';
  }
  if (!hasLow && hasMid && !hasHigh) {
    return '밝은 실내가 좋아요';
  }
  if (!hasLow && !hasMid && hasHigh) {
    return '햇빛이 잘 드는 곳이 필요해요';
  }

  // 그 외에는 원본 텍스트 그대로, 줄바꿈 처리만 함
  return parseHtmlBreaks(sunlightInfo);
}


String growthSpeedToString(GrowthSpeed speed) {
  switch (speed) {
    case GrowthSpeed.slow:
      return '느림';
    case GrowthSpeed.medium:
      return '보통';
    case GrowthSpeed.fast:
      return '빠름';
    default:
      return '정보 없음';
  }
}

// 광도
class LuxDescriptionHelper {
  static String fromLightDemandCodes(List<String> codes) {
    final hasLow = codes.contains('055001');
    final hasMid = codes.contains('055002');
    final hasHigh = codes.contains('055003');

    // --- 3개 다 있는 경우
    if (hasLow && hasMid && hasHigh) {
      return "어두운 곳부터 햇빛 잘 드는 곳까지 모두 잘 자라요 🌥️☀️";
    }

    // --- 중 + 고
    if (!hasLow && hasMid && hasHigh) {
      return "밝은 실내나 햇빛 좋은 곳이 좋아요 🌤️☀️";
    }

    // --- 저 + 중
    if (hasLow && hasMid && !hasHigh) {
      return "어두운 실내부터 밝은 실내까지 잘 자라요 🌥️🌤️";
    }

    // --- 고 + 저
    if (hasLow && !hasMid && hasHigh) {
      return "다양한 환경에서 잘 자라요 🌥️☀️";
    }

    // --- 단일
    if (hasLow && !hasMid && !hasHigh) {
      return "어두운 실내에서도 잘 자라요 🌥️";
    }

    if (!hasLow && hasMid && !hasHigh) {
      return "밝은 실내가 좋아요 🌤️";
    }

    if (!hasLow && !hasMid && hasHigh) {
      return "햇빛이 잘 드는 곳이 필요해요 ☀️";
    }

    // fallback
    return "광량 정보가 부족해요 🌫️";
  }
}


class _HighlightInfoRow extends StatelessWidget {
  final String difficulty;
  final String watering;

  const _HighlightInfoRow({required this.difficulty, required this.watering});

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Row(
        children: [
          _HighlightBox(label: '난이도', value: difficulty),
          _HighlightBox(label: '물주기', value: watering),
        ],
      ),
    );
  }
}

class _HighlightBox extends StatelessWidget {
  final String label;
  final String value;

  const _HighlightBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(value, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

