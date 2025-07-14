part of 'plant_data_bloc.dart';

abstract class PlantDataEvent extends Equatable {
  const PlantDataEvent();

  @override
  List<Object> get props => [];
}

class LoadAllPlantsEvent extends PlantDataEvent {}
