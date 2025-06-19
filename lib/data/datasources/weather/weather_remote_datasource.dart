import 'dart:convert';

import 'package:tium/core/dio/api_client.dart';
import 'package:tium/data/models/weather/weather_model.dart';

abstract class LivingWeatherRemoteDataSource {
  Future<UVIndexDto> fetchUVIndex({
    required String areaCode, // 행정구역 코드
  });
}

class LivingWeatherRemoteDataSourceImpl
    implements LivingWeatherRemoteDataSource {
  LivingWeatherRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<UVIndexDto> fetchUVIndex({required String areaCode}) async {
    final timeStr = getLatestAnnouncementTime();

    final res = await _client.get<dynamic>(
      '/getUVIdxV4',
      query: {
        'areaNo': 110,
        'dataType': 'JSON',
        'time': timeStr,
      },
    );

    // res.data가 Map이 아닐 수 있으므로 안전하게 처리
    Map<String, dynamic> json;
    if (res.data is String) {
      // 수동 파싱
      json = jsonDecode(res.data as String) as Map<String, dynamic>;
    } else if (res.data is Map<String, dynamic>) {
      json = res.data as Map<String, dynamic>;
    } else {
      throw Exception('Unexpected response data type: ${res.data.runtimeType}');
    }

    return UVIndexDto.fromJson(json);
  }

  String getLatestAnnouncementTime() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9)); // 한국시간 기준

    // 3시간 단위로 내림 처리
    final hourGroup = (now.hour ~/ 3) * 3;

    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = hourGroup.toString().padLeft(2, '0');

    return '$year$month$day$hour';
  }
}