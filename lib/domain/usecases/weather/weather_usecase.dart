import 'package:tium/domain/entities/weather/temperature.dart';
import 'package:tium/domain/entities/weather/uvIndex.dart';
import 'package:tium/domain/repositories/weather/weather_repository.dart';

class GetUVIndex {
  GetUVIndex(this._repo);
  final WeatherRepository _repo;
  Future<UVIndex> call(String areaCode) => _repo.getUVIndex(areaCode);
}

class GetCurrentTemperature {
  GetCurrentTemperature(this._repo);
  final WeatherRepository _repo;

  Future<Temperature> call(int nx, int ny) => _repo.getTemperature(nx, ny);
}