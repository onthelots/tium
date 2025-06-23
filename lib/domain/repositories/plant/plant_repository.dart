import 'package:tium/data/models/plant/plant_model.dart';

abstract class PlantRepository {
  Future<List<PlantSummary>> dryGardenPlants();
  Future<List<PlantSummary>> indoorGardenPlants();
  Future<PlantDetail> detail(String id, PlantCategory category);
}