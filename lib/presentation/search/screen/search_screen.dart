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
    return BlocProvider(
      create: (_) => locator<SearchBloc>()..add(SearchLoadedRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('검색'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => showSearch(
                context: context,
                delegate: PlantSearchDelegate(context.read<SearchBloc>()),
              ),
            ),
          ],
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return switch (state) {
              SearchLoading() => const Center(child: CircularProgressIndicator()),
              SearchLoaded() => ListView(children: [
                _PlantSection(title: '건조에 강한 식물', plants: state.dryGarden, category: PlantCategory.dryGarden),
                _PlantSection(title: '실내 정원 식물', plants: state.indoorGarden, category: PlantCategory.indoorGarden),
              ]),
              SearchError() => Center(child: Text(state.message)),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class PlantSearchDelegate extends SearchDelegate {
  PlantSearchDelegate(this.bloc);
  final SearchBloc bloc;

  @override
  String get searchFieldLabel => '식물 이름 검색';

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = bloc.state is SearchLoaded
        ? (bloc.state as SearchLoaded)
        .dryGarden
        .followedBy((bloc.state as SearchLoaded).indoorGarden)
        .where((p) => p.name.contains(query))
        .toList()
        : <PlantSummary>[];

    if (results.isEmpty) {
      return const Center(child: Text('결과가 없습니다.'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final plant = results[index];
        return ListTile(
          leading: Image.network(plant.imageUrl, width: 48, height: 48, fit: BoxFit.cover),
          title: Text(plant.name),
          onTap: () {},
          // onTap: () => Navigator.pushNamed(
          //   context,
          //   Routes.plantDetail,
          //   arguments: {'id': plant.id, 'category': PlantCategory.indoorGarden},
          // ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();
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
    if (plants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final plant = plants[index];
              return GestureDetector(
                onTap: () {
                  // Navigator.pushNamed(context, Routes.plantDetail, arguments: plant.id);
                },
                child: SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      Hero(
                        tag: plant.id,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            plant.imageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: plants.length,
          ),
        ),
      ],
    );
  }
}