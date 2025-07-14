import 'package:tium/data/models/plant/plant_detail_api_model.dart'; // Import new API model
import 'package:tium/data/models/plant/plant_summary_api_model.dart';
import 'package:tium/data/models/user/user_model.dart';

abstract class PlantRepository {
  Future<List<PlantSummaryApiModel>> indoorGardenPlants();

  Future<List<PlantSummaryApiModel>> getPlantsFiltered({
    String? lightChkVal,
    String? lefcolrChkVal,
    String? grwhstleChkVal,
    String? ignSeasonChkVal,
    String? priceType,
    String? waterCycleSel,
    int? size,
  });

  Future<PlantDetailApiModel> detail(String id); // Change return type
}