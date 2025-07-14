import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_cached_image.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/plant/plant_summary_api_model.dart';
import 'package:tium/presentation/home/bloc/plant_section_list/plant_section_list_bloc.dart';
import 'package:tium/presentation/home/bloc/plant_section_list/plant_section_list_event.dart';
import 'package:tium/presentation/home/bloc/plant_section_list/plant_section_list_state.dart';

class PlantSectionListScreen extends StatefulWidget {
  final String title;
  final Map<String, String> filter;
  final int limit;

  const PlantSectionListScreen({
    required this.title,
    required this.filter,
    required this.limit,
    super.key,
  });

  @override
  State<PlantSectionListScreen> createState() => _PlantSectionListScreenState();
}

class _PlantSectionListScreenState extends State<PlantSectionListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FilteredPlantListBloc>().add(
      LoadFilteredPlantsRequested(
        filter: widget.filter,
        limit: widget.limit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.dividerColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.title, style: theme.textTheme.labelLarge,),
      ),
      body: BlocBuilder<FilteredPlantListBloc, FilteredPlantListState>(
        builder: (context, state) {
          if (state is FilteredPlantListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FilteredPlantListError) {
            return Center(
              child: Text(
                '오류: ${state.message}',
                style: theme.textTheme.bodyMedium,
              ),
            );
          } else if (state is FilteredPlantListLoaded) {
            final plants = state.plants;

            if (plants.isEmpty) {
              return Center(
                child: Text(
                  '조건에 맞는 식물이 없어요 😢',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: plants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plant = plants[index];
                return _PlantListTile(plant: plant);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}


class _PlantListTile extends StatelessWidget {
  final PlantSummaryApiModel plant;

  const _PlantListTile({required this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = plant.highResImageUrl ?? plant.imageUrl;
    return InkWell(
      onTap: () {
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
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80,
                height: 80,
                child: buildCachedImage(imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                plant.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
