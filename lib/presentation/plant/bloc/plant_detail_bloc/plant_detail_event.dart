import 'package:tium/data/models/plant/plant_model.dart';

abstract class PlantDetailEvent {}

class PlantDetailRequested extends PlantDetailEvent {
  final String id;
  final PlantCategory category;
  final String name;

  PlantDetailRequested({
    required this.id,
    required this.category,
    required this.name,
  });
}
