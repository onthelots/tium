import 'package:tium/data/models/plant/plant_model.dart';

abstract class FilteredPlantListState {}

class FilteredPlantListInitial extends FilteredPlantListState {}

class FilteredPlantListLoading extends FilteredPlantListState {}

class FilteredPlantListLoaded extends FilteredPlantListState {
  final List<PlantSummary> plants;

  FilteredPlantListLoaded(this.plants);
}

class FilteredPlantListError extends FilteredPlantListState {
  final String message;

  FilteredPlantListError(this.message);
}