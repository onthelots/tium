import 'package:tium/data/models/plant/plant_summary_api_model.dart';

abstract class PlantDetailEvent {}

class PlantDetailRequested extends PlantDetailEvent {
  final String id;

  PlantDetailRequested({
    required this.id,
  });
}
