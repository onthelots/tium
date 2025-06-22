import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:tium/core/dio/api_client.dart';
import 'package:tium/data/models/weather/temperature_dto.dart';
import 'package:tium/data/models/weather/uvIndex_dto.dart';

abstract class WeatherRemoteDataSource {
  Future<UVIndexDto> fetchUVIndex({required String areaNo});
  Future<TemperatureDto> fetchTemperature({required int nx, required int ny});
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  WeatherRemoteDataSourceImpl({
    required this.uvClient,
    required this.tempClient,
  });

  final ApiClient uvClient;
  final ApiClient tempClient;

  // 자외선 지수 ─────────────────────────
  @override
  Future<UVIndexDto> fetchUVIndex({required String areaNo}) async {
    final timeStr = _calcUvTime();        // 3h 단위 h0 용
    final res = await uvClient.get<dynamic>(
      '/getUVIdxV4',
      query: {
        'areaNo'  : areaNo,
        'dataType': 'JSON',
        'time'    : timeStr,
      },
    );
    return UVIndexDto.fromJson(_json(res.data, tag: 'UV'));
  }

  // 기온 ───────────────────────────────
  @override
  Future<TemperatureDto> fetchTemperature({required int nx, required int ny}) async {
    final nowKst   = DateTime.now().toUtc().add(const Duration(hours: 9));
    final date     = '${nowKst.year}${nowKst.month.toString().padLeft(2, '0')}${nowKst.day.toString().padLeft(2, '0')}';
    final baseTime = _calcTempBaseTime(nowKst); // 30분 룰

    final res = await tempClient.get<dynamic>(
      '/getUltraSrtNcst',
      query: {
        'dataType' : 'JSON',
        'base_date': date,
        'base_time': baseTime,  // "HH00"
        'nx'       : '$nx',
        'ny'       : '$ny',
        'numOfRows': '10',
        'pageNo'   : '1',
      },
    );
    return TemperatureDto.fromJson(_json(res.data, tag: 'TEMP'));
  }

  // ───────────────────────── 헬퍼
  Map<String,dynamic> _json(dynamic d, {required String tag}) {
    if (d is Map<String,dynamic>) return d;
    if (d is String) return jsonDecode(d) as Map<String,dynamic>;
    throw Exception('[$tag] Unexpected type: ${d.runtimeType}');
  }

  // 3시간 단위 자외선 time (yyyyMMddHH)
  String _calcUvTime() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    final hour = (now.hour ~/ 3) * 3;
    return '${DateFormat('yyyyMMdd').format(now)}${hour.toString().padLeft(2, '0')}';
  }

  // 기온 base_time (30분 이전이면 한 시간 전)
  String _calcTempBaseTime(DateTime now) {
    var h = now.minute < 30 ? (now.hour - 1) % 24 : now.hour;
    return h.toString().padLeft(2, '0') + '00';
  }
}