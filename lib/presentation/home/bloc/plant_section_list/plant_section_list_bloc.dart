import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/domain/usecases/plant/plants_usecase.dart';
import 'package:tium/presentation/home/bloc/plant_section_list/plant_section_list_event.dart';
import 'package:tium/presentation/home/bloc/plant_section_list/plant_section_list_state.dart';

class FilteredPlantListBloc extends Bloc<FilteredPlantListEvent, FilteredPlantListState> {
  final GetRecommendedPlantsByFilter getPlantsByFilter;

  FilteredPlantListBloc(this.getPlantsByFilter) : super(FilteredPlantListInitial()) {
    on<LoadFilteredPlantsRequested>(_onLoad);
  }

  Future<void> _onLoad(LoadFilteredPlantsRequested event, Emitter<FilteredPlantListState> emit) async {
    emit(FilteredPlantListLoading());

    try {
      final plants = await getPlantsByFilter(event.filter, size: event.limit);
      emit(FilteredPlantListLoaded(plants));
    } catch (e) {
      emit(FilteredPlantListError('식물 정보를 불러오지 못했습니다.'));
    }
  }
}
