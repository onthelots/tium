/// 1) 좌표 값만 필요할 때 ─ LatLng
class LatLng {
  final double lat;
  final double lng;
  LatLng(this.lat, this.lng);
}

/// 2) 지오코딩 결과 (주소 → 좌표)
class GeocodingResult {
  final LatLng latLng;
  GeocodingResult({required this.latLng});

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    final addr = json['addresses'][0];
    final lat  = double.parse(addr['y']);
    final lng  = double.parse(addr['x']);
    return GeocodingResult(latLng: LatLng(lat, lng));
  }
}

/// 3) 리버스 지오코딩 결과 (좌표 → 행정동 코드)
class ReverseGeocodingResult {
  final String areaCode; // 행정동 코드
  final String sido;
  final String sigungu;
  final String dong;
  final String ri;

  ReverseGeocodingResult({
    required this.areaCode,
    required this.sido,
    required this.sigungu,
    required this.dong,
    required this.ri,
  });

  factory ReverseGeocodingResult.fromJson(Map<String, dynamic> json) {
    final adm = (json['results'] as List)
        .firstWhere((e) => e['name'] == 'admcode');

    final region = adm['region'];
    return ReverseGeocodingResult(
      areaCode: adm['code']['id'],
      sido: region['area1']['name'],
      sigungu: region['area2']['name'],
      dong: region['area3']['name'],
      ri: region['area4']['name'] ?? '',
    );
  }
}