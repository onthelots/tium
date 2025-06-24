import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/constants/app_asset.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/presentation/home/bloc/plant_today/plant_today_bloc.dart';
import 'package:tium/presentation/home/bloc/plant_today/plant_today_event.dart';
import 'package:tium/presentation/home/bloc/plant_today/plant_today_state.dart';

/// 이벤트 리스트

class HomeEventList extends StatefulWidget {
  const HomeEventList({super.key});

  @override
  State<HomeEventList> createState() => _HomeEventListState();
}

class _HomeEventListState extends State<HomeEventList> {
  @override
  void initState() {
    super.initState();
    context.read<PlantBloc>().add(LoadPlantSamplesRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<PlantBloc, PlantState>(
      builder: (context, state) {
        if (state is PlantLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PlantLoaded) {
          final indoor = state.indoorSamples;
          final dry = state.drySamples;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('추천 식물',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.recommendPlant,
                          arguments: {
                            'indoor': indoor,
                            'dry': dry,
                          },
                        );
                      },
                      child: Text('더 보기',
                          style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildCompactCards(indoor, dry),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildCompactCards(List<PlantSummary> indoor, List<PlantSummary> dry) {
    final combined = [...indoor.take(2), ...dry.take(2)];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: combined.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final plant = combined[index];
          return _PlantCardItem(plant: plant);
        },
      ),
    );
  }
}

class _PlantCardItem extends StatelessWidget {
  final PlantSummary plant;

  const _PlantCardItem({required this.plant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  plant.highResImageUrl ?? plant.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                plant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }
}
