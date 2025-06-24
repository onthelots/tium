import 'package:tium/data/models/plant/plant_detail_model.dart';
import 'package:tium/data/models/plant/plant_model.dart';

abstract class PlantDetailState {}

class PlantDetailInitial extends PlantDetailState {}

class PlantDetailLoading extends PlantDetailState {}

class PlantDetailLoaded extends PlantDetailState {
  final PlantDetail plant;
  PlantDetailLoaded(this.plant);
}

class PlantDetailError extends PlantDetailState {
  final String message;
  PlantDetailError(this.message);
}