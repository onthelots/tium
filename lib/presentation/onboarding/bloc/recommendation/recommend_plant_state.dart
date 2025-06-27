import 'package:tium/data/models/plant/plant_model.dart';

sealed class RecommendationState {}

class RecommendationInitial extends RecommendationState {}
class RecommendationLoading extends RecommendationState {}
class RecommendationLoaded extends RecommendationState {
  final List<PlantSummary> plants;
  RecommendationLoaded(this.plants);
}
class RecommendationError extends RecommendationState {
  final String message;
  RecommendationError(this.message);
}