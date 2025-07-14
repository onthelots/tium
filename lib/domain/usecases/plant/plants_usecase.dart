import 'package:tium/data/datasources/plant/garden_remote_datasource.dart';
import 'package:tium/data/models/plant/plant_detail_api_model.dart'; // Import new API model
import 'package:tium/data/models/plant/plant_summary_api_model.dart';
import 'package:tium/data/models/plant_preference/plant_preference.dart';

import 'package:tium/domain/repositories/plant/plant_repository.dart';

class GetIndoorGardenPlants {
  final PlantRepository repo;
  GetIndoorGardenPlants(this.repo);
  Future<List<PlantSummaryApiModel>> call() => repo.indoorGardenPlants();
}

class GetPlantDetail {
  GetPlantDetail(this._repo);
  final PlantRepository _repo;

  Future<PlantDetailApiModel> call({ // Change return type
    required String id,
  }) {
    return _repo.detail(id);
  }
}

class GetRecommendedPlantsByFilter {
  final PlantRepository repo;
  GetRecommendedPlantsByFilter(this.repo);

  Future<List<PlantSummaryApiModel>> call(Map<String, String> filter, {int size = 10}) {
    return repo.getPlantsFiltered(
      lightChkVal: filter['lightChkVal'],
      lefcolrChkVal: filter['lefcolrChkVal'],
      grwhstleChkVal: filter['grwhstleChkVal'],
      ignSeasonChkVal: filter['ignSeasonChkVal'],
      priceType: filter['priceType'],
      waterCycleSel: filter['waterCycleSel'],
      size: size,
    );
  }
}