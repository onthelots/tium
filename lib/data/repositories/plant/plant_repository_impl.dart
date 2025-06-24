import 'package:tium/data/datasources/plant/dry_garden_remote_datasource.dart';
import 'package:tium/data/datasources/plant/garden_remote_datasource.dart';
import 'package:tium/data/models/plant/plant_detail_model.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/domain/repositories/plant/plant_repository.dart';

class PlantRepositoryImpl implements PlantRepository {
  final DryGardenRemoteDataSource dryGardenRemote;
  final GardenRemoteDataSource gardenRemote;

  PlantRepositoryImpl({
    required this.dryGardenRemote,
    required this.gardenRemote,
  });

  @override
  Future<List<PlantSummary>> dryGardenPlants() =>
      dryGardenRemote.list(size: 300);

  @override
  Future<List<PlantSummary>> indoorGardenPlants() =>
      gardenRemote.list(size: 300);

  @override
  Future<PlantDetail> detail(String id, PlantCategory category, {required String name}) {
    switch (category) {
      case PlantCategory.dryGarden:
        return dryGardenRemote.detail(id); // dryGarden에는 name 필요 없음
      case PlantCategory.indoorGarden:
        return gardenRemote.detail(id, name: name); // name 전달!
    }
  }
}