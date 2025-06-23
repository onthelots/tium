import 'package:tium/domain/entities/weather/weather.dart';
import 'package:tium/domain/entities/weather/uvIndex.dart';

abstract class WeatherRepository {
  Future<UVIndex> getUVIndex(String areaCode);
  Future<Weather> getTemperature(int nx, int ny);
}