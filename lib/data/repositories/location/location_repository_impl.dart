import 'package:tium/data/datasources/location/location_remote_datasource.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/domain/repositories/location/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl(this.remote);

  final LocationRemoteDataSource remote;

  @override
  Future<UserLocation> findByAddress(String address) async {
    final locationQuery = await remote.geocode(address); // 1 지오코딩
    final reverseGCResult = await remote.reverseGeocode(
      locationQuery.lat,
      locationQuery.lng,
    );
    return UserLocation(
      lat: locationQuery.lat,
      lng: locationQuery.lng,
      areaCode: reverseGCResult.areaCode,
      sido: reverseGCResult.sido,
      sigungu: reverseGCResult.sigungu,
      dong: reverseGCResult.dong,
      ri: reverseGCResult.ri,
    );
  }

  @override
  Future<UserLocation> findByLatLng(double lat, double lng) async {
    final reverseGCResult = await remote.reverseGeocode(lat, lng); // 1 리버스 지오코딩
    return UserLocation(
      lat: lat,
      lng: lng,
      areaCode: reverseGCResult.areaCode,
      sido: reverseGCResult.sido,
      sigungu: reverseGCResult.sigungu,
      dong: reverseGCResult.dong,
      ri: reverseGCResult.ri,
    );
  }
}
