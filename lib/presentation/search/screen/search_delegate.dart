import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_loading_indicator.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_bloc.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_state.dart';

class PlantSearchDelegate extends SearchDelegate {
  PlantSearchDelegate(this.allPlants);

  final List<PlantSummary> allPlants;

  @override
  String get searchFieldLabel => '이름을 입력해주세요';

  @override
  TextStyle? get searchFieldStyle => TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.w500,
    fontSize: 15.0,
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
    final blocState = context.watch<SearchBloc>().state;

    if (blocState is! SearchLoaded) {
      return CustomLoadingIndicator(message: '식물정보를 불러오는 중이에요',);
    }

    final results = query.isEmpty
        ? (List<PlantSummary>.from(blocState.dryGarden + blocState.indoorGarden)
      ..sort((a, b) => a.name.compareTo(b.name)))
        : (blocState.dryGarden + blocState.indoorGarden)
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(child: Text('검색 결과가 없습니다.', style: theme.textTheme.bodyMedium));
    }

    return ListView.separated(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final plant = results[index];
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
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
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            tileColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}