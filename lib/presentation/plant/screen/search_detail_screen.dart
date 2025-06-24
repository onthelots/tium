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
          name: name, // 👈 여기에 식물 이름 전달
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
                    pinned: false,
                    stretch: true,
                    onStretchTrigger: () async {
                      // 추가 작업 가능
                    },
                    stretchTriggerOffset: 100,
                    expandedHeight: 300,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    leading: null, // 기본 자동 생기지 않음

                    actions: [
                      Container(
                        margin: const EdgeInsets.only(top: 15, right: 15),
                        decoration: BoxDecoration(
                          color: theme.disabledColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 25),
                          tooltip: '닫기',
                          onPressed: () => Navigator.of(context).pop(),
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
                          shadows: [
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
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                        )
                            : Container(color: Colors.grey[300]),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _HighlightInfoRow(
                          difficulty: difficultyLevelToString(plant.difficultyLevel),
                          watering: plant.wateringInfo ?? '정보 없음',
                        ),
                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '📋 식물 관리 정보',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),

                        _InfoCard(label: '성장 특성', value: plant.growthInfo, icon: Icons.eco),
                        _InfoCard(label: '번식 방법', value: plant.propagationMethod, icon: Icons.grass),
                        _InfoCard(label: '광량 정보', value: plant.sunlightInfo, icon: Icons.wb_sunny),
                        _InfoCard(label: '성장 속도', value: growthSpeedToString(plant.growthSpeed), icon: Icons.speed),
                        const SizedBox(height: 40),
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(icon, color: Colors.green[400], size: 24),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
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
      return '정보 없음';
  }
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

class _HighlightInfoRow extends StatelessWidget {
  final String difficulty;
  final String watering;

  const _HighlightInfoRow({required this.difficulty, required this.watering});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.green[900] : Colors.green[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _HighlightBox(
            icon: Icons.emoji_people,
            label: '난이도',
            value: difficulty,
          ),
          const SizedBox(width: 16),
          _HighlightBox(
            icon: Icons.water_drop,
            label: '물주기',
            value: watering,
          ),
        ],
      ),
    );
  }
}

class _HighlightBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HighlightBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green[700], size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.green[800]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

