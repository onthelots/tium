import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/domain/usecases/plant/plants_usecase.dart';
import 'package:tium/presentation/home/bloc/plant_today/plant_today_event.dart';
import 'package:tium/presentation/home/bloc/plant_today/plant_today_state.dart';

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final GetDryGardenPlants getDry;
  final GetIndoorGardenPlants getIndoor;

  PlantBloc({required this.getDry, required this.getIndoor}) : super(PlantInitial()) {
    on<LoadPlantSamplesRequested>(_onLoad);
  }

  Future<void> _onLoad(LoadPlantSamplesRequested event, Emitter<PlantState> emit) async {
    emit(PlantLoading());
    try {
      final dryList = await getDry();
      final indoorList = await getIndoor();

      dryList.shuffle();
      indoorList.shuffle();

      final drySample = dryList.take(5).toList();
      final indoorSample = indoorList.take(5).toList();

      emit(PlantLoaded(drySamples: drySample, indoorSamples: indoorSample));
    } catch (e) {
      emit(PlantError('식물 데이터를 불러오지 못했어요.'));
    }
  }
}
