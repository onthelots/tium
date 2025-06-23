import 'package:tium/data/datasources/plant/dry_garden_remote_datasource.dart';
import 'package:tium/data/datasources/plant/garden_remote_datasource.dart';
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
      dryGardenRemote.list(size: 5);

  @override
  Future<List<PlantSummary>> indoorGardenPlants() =>
      gardenRemote.list(size: 5);

  @override
  Future<PlantDetail> detail(String id, PlantCategory category) {
    switch (category) {
      case PlantCategory.dryGarden:
        return dryGardenRemote.detail(id);
      case PlantCategory.indoorGarden:
      case PlantCategory.beginner:
        return gardenRemote.detail(id);
    }
  }
}