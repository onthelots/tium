import 'package:equatable/equatable.dart';
import 'package:tium/data/models/plant/plant_summary_api_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<PlantSummaryApiModel> plants;
  final String query; // Add query to state

  const SearchLoaded({
    required this.plants,
    this.query = '', // Default empty query
  });

  @override
  List<Object> get props => [plants, query];

  SearchLoaded copyWith({
    List<PlantSummaryApiModel>? plants,
    String? query,
  }) {
    return SearchLoaded(
      plants: plants ?? this.plants,
      query: query ?? this.query,
    );
  }
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}
