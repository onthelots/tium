import 'package:flutter/material.dart';
import 'package:tium/components/custom_cached_image.dart';
import 'package:tium/data/models/plant/plant_model.dart';

class SmallPlantCard extends StatelessWidget {
  final PlantSummary plant;
  final VoidCallback? onTap;

  const SmallPlantCard({required this.plant, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = plant.highResImageUrl ?? plant.imageUrl;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        height: 140,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 이미지
              buildCachedImage(imageUrl), // shimmer + cached 이미지

              // 어두운 오버레이
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // 텍스트 (좌하단)
              // 텍스트 (좌하단)
              Positioned(
                left: 10,
                bottom: 10,
                child: SizedBox(
                  width: 120, // SizedBox 너비(140)에서 좌우 여백 감안해 최대 너비 지정
                  child: Text(
                    plant.name ?? '이름 없음',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false, // 줄바꿈 방지 (선택 사항)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
