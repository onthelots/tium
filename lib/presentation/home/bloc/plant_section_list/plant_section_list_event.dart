abstract class FilteredPlantListEvent {}

class LoadFilteredPlantsRequested extends FilteredPlantListEvent {
  final Map<String, String> filter;
  final int limit;

  LoadFilteredPlantsRequested({required this.filter, this.limit = 20});
}