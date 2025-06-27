import 'package:tium/domain/entities/plant/plant_section.dart';

sealed class RecommendationSectionState {}

class RecommendationSectionInitial extends RecommendationSectionState {}
class RecommendationSectionLoading extends RecommendationSectionState {}
class RecommendationSectionLoaded extends RecommendationSectionState {
  final List<PlantSection> sections;
  RecommendationSectionLoaded(this.sections);
}
class RecommendationSectionError extends RecommendationSectionState {
  final String message;
  RecommendationSectionError(this.message);
}