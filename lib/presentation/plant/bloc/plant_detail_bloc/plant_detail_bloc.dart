import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/domain/usecases/plant/plants_usecase.dart';
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_event.dart';
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_state.dart';

class PlantDetailBloc extends Bloc<PlantDetailEvent, PlantDetailState> {
  final GetPlantDetail getPlantDetail;

  PlantDetailBloc(this.getPlantDetail) : super(PlantDetailInitial()) {
    on<PlantDetailRequested>(_onRequested);
  }

  Future<void> _onRequested(
      PlantDetailRequested event,
      Emitter<PlantDetailState> emit,
      ) async {
    emit(PlantDetailLoading());
    try {
      final detail = await getPlantDetail(
        id: event.id,
      );

      emit(PlantDetailLoaded(detail));
    } catch (e, stack) {
      debugPrint('PlantDetailBloc Error: $e');
      debugPrint('$stack');
      emit(PlantDetailError('식물 정보를 불러오지 못했습니다.'));
    }
  }
}