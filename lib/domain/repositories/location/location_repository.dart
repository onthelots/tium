import 'package:tium/data/models/user/user_model.dart';

abstract class LocationRepository {
  Future<UserLocation> findByAddress(String address); // 검색 > 좌표 > 행정동 (geocoding + reverse geocoding)
  Future<UserLocation> findByLatLng(double lat, double lng); // 좌표 정보 > 행정동 (reverse geocoding)
}