import 'package:tium/data/datasources/plant/dry_garden_remote_datasource.dart';
import 'package:tium/data/datasources/plant/garden_remote_datasource.dart';
import 'package:tium/data/models/plant/plant_detail_model.dart';
import 'package:tium/data/models/plant/plant_model.dart';
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
