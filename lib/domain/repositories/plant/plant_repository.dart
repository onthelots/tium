import 'package:tium/data/models/plant/plant_detail_model.dart';
import 'package:tium/data/models/plant/plant_model.dart';

abstract class PlantRepository {
  Future<List<PlantSummary>> dryGardenPlants();
  Future<List<PlantSummary>> indoorGardenPlants();

  Future<List<PlantSummary>> getPlantsFiltered({
    String? lightChkVal,
    String? lefcolrChkVal,
    String? grwhstleChkVal,
    String? ignSeasonChkVal,
    String? priceType,
    String? waterCycleSel,
    int? size,
  });

  Future<PlantDetail> detail(String id, PlantCategory category, {required String name});
}