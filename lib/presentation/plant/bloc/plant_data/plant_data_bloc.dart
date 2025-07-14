import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tium/data/models/plant/plant_summary_api_model.dart'; // Assuming Plant model path
import 'package:tium/domain/usecases/plant/plants_usecase.dart'; // GetIndoorGardenPlants use case

part 'plant_data_event.dart';
part 'plant_data_state.dart';

class PlantDataBloc extends Bloc<PlantDataEvent, PlantDataState> {
  final GetIndoorGardenPlants getIndoorGardenPlants;

  PlantDataBloc({required this.getIndoorGardenPlants}) : super(PlantDataInitial()) {
    on<LoadAllPlantsEvent>(_onLoadAllPlants);
  }

  Future<void> _onLoadAllPlants(
    LoadAllPlantsEvent event,
    Emitter<PlantDataState> emit,
  ) async {
    emit(PlantDataLoading());
    try {
      final plants = await getIndoorGardenPlants.call();
      print("🌿전체 식물 데이터 불러오기 완료, 총 갯수 : ${plants.length}");
      emit(PlantDataLoaded(plants: plants));
    } catch (e) {
      emit(PlantDataError(message: e.toString()));
    }
  }
}
