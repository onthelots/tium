import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/domain/usecases/plant/plants_usecase.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_event.dart' show SearchEvent, SearchLoadedRequested;
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GetDryGardenPlants getDryGardenPlants;
  final GetIndoorGardenPlants getIndoorGardenPlants;

  SearchBloc({
    required this.getDryGardenPlants,
    required this.getIndoorGardenPlants,
  }) : super(SearchInitial()) {
    on<SearchLoadedRequested>(_onLoaded);
  }

  Future<void> _onLoaded(SearchLoadedRequested event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      debugPrint('[SearchBloc] 요청 시작');

      final dry = await getDryGardenPlants();
      debugPrint('[SearchBloc] 건조 식물 수: ${dry.length}');

      final indoor = await getIndoorGardenPlants();
      debugPrint('[SearchBloc] 실내 식물 수: ${indoor.length}');

      emit(SearchLoaded(
        dryGarden: dry,
        indoorGarden: indoor,
      ));

      debugPrint('[SearchBloc] 성공적으로 로딩됨');
    } catch (e, stack) {
      debugPrint('[SearchBloc] 오류 발생: \$e');
      debugPrintStack(stackTrace: stack);
      emit(SearchError(e.toString()));
    }
  }
}