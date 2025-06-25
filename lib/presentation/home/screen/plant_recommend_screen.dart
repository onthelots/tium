import 'package:flutter/material.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/plant/plant_model.dart';

class PlantRecommendScreen extends StatelessWidget {
  final List<PlantSummary> indoorPlants;
  final List<PlantSummary> dryPlants;

  const PlantRecommendScreen({
    super.key,
    required this.indoorPlants,
    required this.dryPlants,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final combined = [...indoorPlants, ...dryPlants];

    return CustomScaffold(
      title: "추천 식물",
      body: ListView.separated(
        itemCount: combined.length,
        itemBuilder: (context, index) {
          final plant = combined[index];
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  plant.highResImageUrl ?? plant.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported,
                      color: theme.colorScheme.onSurface.withOpacity(0.3)),
                ),
              ),
              title: Text(
                plant.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600),
              ),
              tileColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              splashColor: theme.colorScheme.secondary.withOpacity(0.3),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.plantDetail,
                  arguments: {
                    'id': plant.id,
                    'category': plant.category,
                    'imageUrl': plant.highResImageUrl ?? plant.imageUrl,
                    'name': plant.name,
                  },
                );
              },
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 10),
      ),
    );
  }
}
