import 'package:tium/data/datasources/plant/garden_remote_datasource.dart';
import 'package:tium/data/datasources/plant/plant_local_datasource.dart';
import 'package:tium/data/models/plant/plant_detail_api_model.dart'; // Import new API model
import 'package:tium/data/models/plant/plant_summary_api_model.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/domain/repositories/plant/plant_repository.dart';
import 'dart:async';

class PlantRepositoryImpl implements PlantRepository {
  final GardenRemoteDataSource gardenRemote;
  final PlantLocalDataSource plantLocalDataSource;

  PlantRepositoryImpl({
    required this.gardenRemote,
    required this.plantLocalDataSource,
  });

  @override
  Future<List<PlantSummaryApiModel>> indoorGardenPlants() async {
    try {
      final remotePlants = await gardenRemote
          .list(size: 300)
          .timeout(const Duration(seconds: 4));
      return remotePlants;
    } on TimeoutException {
      print('⏰ Timeout: remote API 실패 → Supabase 캐시 사용');
      final cached = await plantLocalDataSource.getPlants();
      if (cached.isNotEmpty) {
        print('📦 Supabase fallback 데이터 사용 (총 ${cached.length}개)');
        return cached;
      }

      print('📭 Supabase도 비어 있음. 👉 최초 초기화 시도');
      final initialized = await _initializePlantDataFromRemote();
      if (initialized) {
        final retry = await plantLocalDataSource.getPlants();
        if (retry.isNotEmpty) {
          print('🌱 초기화 후 Supabase에서 재시도 성공');
          return retry;
        }
      }

      throw Exception("❌ 데이터 없음: 초기화 실패. 네트워크 상태를 확인해주세요.");
    } catch (e) {
      print('❌ 기타 오류 발생: $e → Supabase fallback 시도');
      final cached = await plantLocalDataSource.getPlants();
      return cached;
    }
  }

  @override
  Future<List<PlantSummaryApiModel>> getPlantsFiltered({
    String? lightChkVal,
    String? lefcolrChkVal,
    String? grwhstleChkVal,
    String? ignSeasonChkVal,
    String? priceType,
    String? waterCycleSel,
    int? size,
  }) async {
    final gardenPlants = await gardenRemote.list(
      lightChkVal: lightChkVal,
      lefcolrChkVal: lefcolrChkVal,
      grwhstleChkVal: grwhstleChkVal,
      ignSeasonChkVal: ignSeasonChkVal,
      priceType: priceType,
      waterCycleSel: waterCycleSel,
      size: size ?? 20,
    );

    gardenPlants.shuffle();

    return gardenPlants.length > (size ?? 20)
        ? gardenPlants.sublist(0, size)
        : gardenPlants;
  }

  @override
  Future<PlantDetailApiModel> detail(String id) { // Change return type
    return gardenRemote.detail(id);
  }

  Future<bool> _initializePlantDataFromRemote() async {
    try {
      final remotePlants = await gardenRemote.list(size: 300);
      if (remotePlants.isNotEmpty) {
        await plantLocalDataSource.savePlants(remotePlants);
        print('🌱 최초 데이터 초기화 완료 (${remotePlants.length}개)');
        return true;
      } else {
        print('⚠️ remotePlants 비어 있음');
        return false;
      }
    } catch (e) {
      print('❌ 초기화 중 오류 발생: $e');
      return false;
    }
  }
}