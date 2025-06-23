import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:tium/core/dio/api_client.dart';
import 'package:tium/data/models/weather/weather_dto.dart';
import 'package:tium/data/models/weather/uvIndex_dto.dart';

abstract class WeatherRemoteDataSource {
  Future<UVIndexDto> fetchUVIndex({required String areaNo});
  Future<WeatherDto> fetchWeather({required int nx, required int ny});
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  WeatherRemoteDataSourceImpl({
    required this.uvClient,
    required this.tempClient,
  });

  final ApiClient uvClient;
  final ApiClient tempClient;

  @override
  Future<UVIndexDto> fetchUVIndex({required String areaNo}) async {
    final timeStr = _calcUvTime();
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

  @override
  Future<WeatherDto> fetchWeather({required int nx, required int ny}) async {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9)); // KST
    final base = _calcFcstBaseTime(now);

    final res = await tempClient.get<dynamic>(
      '/getUltraSrtFcst',
      query: {
        'dataType' : 'JSON',
        'base_date': DateFormat('yyyyMMdd').format(now),
        'base_time': base,    // "HH30"
        'nx'       : '$nx',
        'ny'       : '$ny',
        'numOfRows': '100',
        'pageNo'   : '1',
      },
    );

    return WeatherDto.fromJson(_json(res.data, tag: 'Weather'));
  }

  Map<String, dynamic> _json(dynamic d, {required String tag}) {
    if (d is Map<String, dynamic>) return d;
    if (d is String) return jsonDecode(d) as Map<String, dynamic>;
    throw Exception('[$tag] Unexpected type: ${d.runtimeType}');
  }

  String _calcUvTime() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    final hour = (now.hour ~/ 3) * 3;
    return '${DateFormat('yyyyMMdd').format(now)}${hour.toString().padLeft(2, '0')}';
  }

  String _calcFcstBaseTime(DateTime now) {
    final h = now.minute < 30 ? (now.hour - 1) % 24 : now.hour;
    return '${h.toString().padLeft(2, '0')}30';
  }
}