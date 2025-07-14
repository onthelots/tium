import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/data/models/plant/plant_category_model.dart';
import 'package:tium/data/models/plant/plant_summary_api_model.dart'; // Contains PlantSummary and PlantCategory
import 'package:tium/presentation/plant/bloc/plant_data/plant_data_bloc.dart'; // Import PlantDataBloc
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_event.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_state.dart';
import 'dart:async'; // For StreamSubscription

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final PlantDataBloc plantDataBloc;
  late StreamSubscription _plantDataSubscription;
  List<PlantSummaryApiModel> _allPlants = [];

  SearchBloc({
    required this.plantDataBloc,
  }) : super(SearchInitial()) {
    print("검색 초기화 실시");

    // Check the current state of PlantDataBloc immediately
    if (plantDataBloc.state is PlantDataLoaded) {
      final plantDataLoadedState = plantDataBloc.state as PlantDataLoaded;
      _allPlants = plantDataLoadedState.plants.map((p) => PlantSummaryApiModel(
        id: p.id,
        name: p.name,
        imageUrl: p.highResImageUrl ?? p.imageUrl,
        category: PlantCategory.indoorGarden,
      )).toList();
      // Directly emit the state if data is already loaded
      emit(SearchLoaded(plants: _allPlants)); // <--- Changed this line
      print("초기 PlantDataBloc 상태에서 식물 데이터 로드됨"); // Add a print for debugging
    }

    _plantDataSubscription = plantDataBloc.stream.listen((state) {
      if (state is PlantDataLoaded) {
        print("전체 식물데이터가 불러와져 있습니다");
        _allPlants = state.plants.map((p) => PlantSummaryApiModel(
          id: p.id,
          name: p.name,
          imageUrl: p.highResImageUrl ?? p.imageUrl,
          category: PlantCategory.indoorGarden,
        )).toList();
        add(SearchLoadedRequested()); // Keep this as an add() for subsequent updates
      } else if (state is PlantDataError) {
        emit(SearchError(state.message));
      }
    });

    // Keep event handlers registered at the end of the constructor
    on<SearchLoadedRequested>(_onLoaded);
    on<SearchQueryChanged>(_onQueryChanged);
  }

  Future<void> _onLoaded(
    SearchLoadedRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (_allPlants.isEmpty) {
      print("_allPlants : ${_allPlants.length}");
      emit(SearchLoading()); // Only show loading if plants are not yet loaded
    } else {
      emit(SearchLoaded(plants: _allPlants)); // Show all plants initially
    }
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.toLowerCase();
    if (query.isEmpty) {
      emit(SearchLoaded(plants: _allPlants)); // If query is empty, show all plants
    } else {
      final filteredPlants = _allPlants.where((plant) {
        return plant.name.toLowerCase().contains(query);
      }).toList();
      emit(SearchLoaded(plants: filteredPlants, query: event.query));
    }
  }

  @override
  Future<void> close() {
    _plantDataSubscription.cancel();
    return super.close();
  }
}
