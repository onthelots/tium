import 'package:tium/data/datasources/plant/dry_garden_remote_datasource.dart';
import 'package:tium/data/datasources/plant/garden_remote_datasource.dart';
import 'package:tium/data/models/plant/plant_detail_model.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/data/models/plant_preference/plant_preference.dart';
import 'package:tium/domain/repositories/plant/plant_repository.dart';

class GetDryGardenPlants {
  final PlantRepository repo;
  GetDryGardenPlants(this.repo);
  Future<List<PlantSummary>> call() => repo.dryGardenPlants();
}

class GetIndoorGardenPlants {
  final PlantRepository repo;
  GetIndoorGardenPlants(this.repo);
  Future<List<PlantSummary>> call() => repo.indoorGardenPlants();
}

class GetPlantDetail {
  GetPlantDetail(this._repo);
  final PlantRepository _repo;

  Future<PlantDetail> call({
    required String id,
    required PlantCategory category,
    required String name, // 👈 추가
  }) {
    return _repo.detail(id, category, name: name); // 👈 전달
  }
}

class GetRecommendedPlants {
  final PlantRepository repo;
  GetRecommendedPlants(this.repo);

  Future<List<PlantSummary>> call(UserPlantPreference pref) {
    return repo.getPlantsFiltered(
      lightChkVal: pref.lightChkVal,
      lefcolrChkVal: pref.lefcolrChkVal,
      grwhstleChkVal: pref.grwhstleChkVal,
      ignSeasonChkVal: pref.ignSeasonChkVal,
      priceType: pref.priceType,
      waterCycleSel: pref.waterCycleSel,
    );
  }
}

class GetRecommendedPlantsByFilter {
  final PlantRepository repo;
  GetRecommendedPlantsByFilter(this.repo);

  Future<List<PlantSummary>> call(Map<String, String> filter, {int size = 10}) {
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
