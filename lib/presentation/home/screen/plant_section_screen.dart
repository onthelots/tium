import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/domain/usecases/plant/plants_usecase.dart';
import 'package:tium/presentation/home/bloc/plant_section_list/plant_section_list_bloc.dart';
import 'package:tium/presentation/home/bloc/plant_section_list/plant_section_list_event.dart';
import 'package:tium/presentation/home/bloc/plant_section_list/plant_section_list_state.dart';

class RecommendationFilteredPlantListScreen extends StatefulWidget {
  final String title;
  final Map<String, String> filter;
  final int limit;

  const RecommendationFilteredPlantListScreen({
    required this.title,
    required this.filter,
    this.limit = 20,
    super.key,
  });

  @override
  State<RecommendationFilteredPlantListScreen> createState() => _RecommendationFilteredPlantListScreenState();
}

class _RecommendationFilteredPlantListScreenState extends State<RecommendationFilteredPlantListScreen> {

  @override
  void initState() {
    super.initState();
    print("Filter : ${widget.filter}");
    context.read<FilteredPlantListBloc>().add(LoadFilteredPlantsRequested(filter: widget.filter, limit: widget.limit));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: BlocBuilder<FilteredPlantListBloc, FilteredPlantListState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          if (state is FilteredPlantListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FilteredPlantListError) {
            return Center(
                child: Text(state.message, style: theme.textTheme.bodyMedium));
          } else if (state is FilteredPlantListLoaded) {
            final plants = state.plants;

            if (plants.isEmpty) {
              return Center(child: Text(
                  '해당 조건에 맞는 식물이 없습니다.', style: theme.textTheme.bodyMedium));
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: plants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final plant = plants[index];

                return Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        plant.highResImageUrl ?? plant.imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.image_not_supported,
                                color: theme.colorScheme.onSurface.withOpacity(
                                    0.3)),
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
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
