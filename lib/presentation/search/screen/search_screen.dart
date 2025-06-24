import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/di/locator.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_bloc.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_event.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => locator<SearchBloc>()..add(SearchLoadedRequested()),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('식물검색'),
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          actions: [
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoaded) {
                  final allPlants = [...state.dryGarden, ...state.indoorGarden];
                  return IconButton(
                    icon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: PlantSearchDelegate(allPlants),
                      );
                    },
                    tooltip: '검색',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return switch (state) {
              SearchLoading() => const Center(child: CircularProgressIndicator()),
              SearchLoaded() => ListView(children: [
                _PlantSection(
                  title: '건조에 강한 식물',
                  plants: state.dryGarden,
                  category: PlantCategory.dryGarden,
                ),
                _PlantSection(
                  title: '실내 정원 식물',
                  plants: state.indoorGarden,
                  category: PlantCategory.indoorGarden,
                ),
              ]),
              SearchError() => Center(child: Text(state.message, style: theme.textTheme.bodyLarge)),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class PlantSearchDelegate extends SearchDelegate {
  PlantSearchDelegate(this.allPlants);

  final List<PlantSummary> allPlants;

  @override
  String get searchFieldLabel => '식물이름 검색';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.w500,
  );

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => query = '',
      tooltip: '검색어 지우기',
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.chevron_left_rounded),
    onPressed: () => close(context, null),
    tooltip: '뒤로가기',
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    final results = query.isEmpty
        ? (List<PlantSummary>.from(allPlants)
      ..sort((a, b) => a.name.compareTo(b.name)))
        : allPlants.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();

    if (results.isEmpty) {
      return Center(child: Text('검색 결과가 없습니다.', style: theme.textTheme.bodyMedium));
    }

    return ListView.separated(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final plant = results[index];
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor, // 배경색 여기서 변경
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
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.image_not_supported,
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
                borderRadius: BorderRadius.circular(12)),
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
      }, separatorBuilder: (BuildContext context, int index) {
      return SizedBox(
        height: 10.0,
      );
    },
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}

class _PlantSection extends StatelessWidget {
  final String title;
  final List<PlantSummary> plants;
  final PlantCategory category;

  const _PlantSection({
    required this.title,
    required this.plants,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (plants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(title, style: theme.textTheme.titleLarge),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: plants.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final plant = plants[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.plantDetail,
                    arguments: {
                      'id': plant.id,
                      'category': category,
                      'imageUrl': plant.highResImageUrl ?? plant.imageUrl,
                      'name': plant.name,
                    },
                  );
                },
                child: SizedBox(
                  width: 130,
                  child: Column(
                    children: [
                      Hero(
                        tag: plant.id,
                        child: Material(
                          color: Colors.transparent,
                          elevation: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              plant.highResImageUrl ?? plant.imageUrl,
                              width: 130,
                              height: 130,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
