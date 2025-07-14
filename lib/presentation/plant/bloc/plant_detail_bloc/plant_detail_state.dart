import 'package:tium/data/models/plant/plant_detail_api_model.dart'; // Import new API model

abstract class PlantDetailState {}

class PlantDetailInitial extends PlantDetailState {}

class PlantDetailLoading extends PlantDetailState {}

class PlantDetailLoaded extends PlantDetailState {
  final PlantDetailApiModel plant; // Change type to PlantDetailApiModel
  PlantDetailLoaded(this.plant);
}

class PlantDetailError extends PlantDetailState {
  final String message;
  PlantDetailError(this.message);
}