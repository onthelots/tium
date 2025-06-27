import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class PlantSectionShimmer extends StatelessWidget {
  const PlantSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget shimmerBox({double width = 120, double height = 160, BorderRadius? radius}) {
      return Shimmer(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: theme.dividerColor.withOpacity(0.2),
            borderRadius: radius ?? BorderRadius.circular(12),
          ),
        ),
      );
    }

    Widget shimmerTitle({double width = 100}) {
      return Shimmer(
        child: Container(
          width: width,
          height: 18,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.dividerColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(2, (sectionIndex) {
        final isLarge = sectionIndex == 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: shimmerTitle(width: 120),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: isLarge ? 200 : 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: isLarge ? 2 : 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) {
                    return shimmerBox(
                      width: isLarge ? 160 : 100,
                      height: isLarge ? 200 : 140,
                      radius: BorderRadius.circular(16),
                    );
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
