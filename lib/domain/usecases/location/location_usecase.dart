import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/domain/repositories/location/location_repository.dart';

// 1. 위치정보 검색
class FindLocationByAddress {
  FindLocationByAddress(this.repo);
  final LocationRepository repo;
  Future<UserLocation> call(String query) => repo.findByAddress(query);
}

// 2. 위치정보 공개
class FindLocationByLatLng {
  final LocationRepository repo;
  FindLocationByLatLng(this.repo);

  Future<UserLocation> call(double lat, double lng) => repo.findByLatLng(lat, lng);
}