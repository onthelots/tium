import 'package:tium/domain/entities/weather/temperature.dart';
import 'package:tium/domain/entities/weather/uvIndex.dart';

abstract class WeatherRepository {
  Future<UVIndex> getUVIndex(String areaCode);
  Future<Temperature> getTemperature(int nx, int ny);
}