import 'package:tium/domain/entities/weather/weather_entity.dart';

abstract class LivingWeatherRepository {
  Future<UVIndex> getUVIndex(String areaCode);
}