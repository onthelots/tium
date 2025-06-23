import 'package:tium/data/models/plant/plant_model.dart';

abstract class SearchState {}
class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<PlantSummary> dryGarden;
  final List<PlantSummary> indoorGarden;

  SearchLoaded({
    required this.dryGarden,
    required this.indoorGarden,
  });
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}