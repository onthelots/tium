part of 'plant_data_bloc.dart';

abstract class PlantDataState extends Equatable {
  const PlantDataState();

  @override
  List<Object> get props => [];
}

class PlantDataInitial extends PlantDataState {}

class PlantDataLoading extends PlantDataState {}

class PlantDataLoaded extends PlantDataState {
  final List<PlantSummaryApiModel> plants;

  const PlantDataLoaded({required this.plants});

  @override
  List<Object> get props => [plants];
}

class PlantDataError extends PlantDataState {
  final String message;

  const PlantDataError({required this.message});

  @override
  List<Object> get props => [message];
}
