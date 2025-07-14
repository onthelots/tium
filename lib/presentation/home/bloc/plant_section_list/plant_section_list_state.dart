import 'package:tium/data/models/plant/plant_summary_api_model.dart';

abstract class FilteredPlantListState {}

class FilteredPlantListInitial extends FilteredPlantListState {}

class FilteredPlantListLoading extends FilteredPlantListState {}

class FilteredPlantListLoaded extends FilteredPlantListState {
  final List<PlantSummaryApiModel> plants;

  FilteredPlantListLoaded(this.plants);
}

class FilteredPlantListError extends FilteredPlantListState {
  final String message;

  FilteredPlantListError(this.message);
}