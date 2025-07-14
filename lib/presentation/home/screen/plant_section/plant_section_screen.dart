import 'package:flutter/material.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/plant/plant_summary_api_model.dart';
import 'package:tium/domain/entities/plant/plant_section.dart';
import 'package:tium/presentation/home/screen/plant_section/plant_section_card_large.dart';
import 'package:tium/presentation/home/screen/plant_section/plant_section_card_small.dart';

class PlantSectionScreen extends StatelessWidget {
  final List<PlantSection> sections;
  final void Function(String title, Map<String, String> filter) onSeeMore;

  const PlantSectionScreen({
    Key? key,
    required this.sections,
    required this.onSeeMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '추천 식물이 없습니다.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(sections.length, (index) {
        final section = sections[index];
        final isLarge = index == 0; // 첫 번째 섹션은 Large, 두 번째는 Small

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 + 더보기
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ⬇️ Flexible로 감싸고, overflow 설정
                    Flexible(
                      child: Text(
                        section.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (section.filter != null)
                      TextButton(
                        onPressed: () => onSeeMore(section.title, section.filter!),
                        child: Text("더보기", style: theme.textTheme.labelSmall?.copyWith(color: theme.disabledColor)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              isLarge
                  ? SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: section.plants.length.clamp(0, 2), // 최대 2개
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final plant = section.plants[idx];
                    return LargePlantCard(plant: plant, onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.plantDetail,
                        arguments: {
                          'id': plant.id,
                          'name': plant.name,
                          'category': plant.category,
                          'imageUrl': plant.highResImageUrl ?? plant.imageUrl,
                        },
                      );
                    },);
                  },
                ),
              )
                  : SizedBox(
                    height: 140,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: section.plants.length.clamp(0, 4), // 최대 4개
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final plant = section.plants[index];
                        return SmallPlantCard(plant: plant, onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.plantDetail,
                            arguments: {
                              'id': plant.id,
                              'name': plant.name,
                              'category': plant.category,
                              'imageUrl': plant.highResImageUrl ??
                                  plant.imageUrl,
                            },
                          );
                        },);
                      },
                    ),
                  ),
            ],
          ),
        );
      }),
    );
  }
}
