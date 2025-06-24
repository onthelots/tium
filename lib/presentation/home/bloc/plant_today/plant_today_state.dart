import 'package:tium/data/models/plant/plant_model.dart';

abstract class PlantState {}

class PlantInitial extends PlantState {}

class PlantLoading extends PlantState {}

class PlantLoaded extends PlantState {
  final List<PlantSummary> drySamples;
  final List<PlantSummary> indoorSamples;

  PlantLoaded({required this.drySamples, required this.indoorSamples});
}

class PlantError extends PlantState {
  final String message;
  PlantError(this.message);
}
