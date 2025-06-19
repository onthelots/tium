import 'package:tium/domain/entities/weather/weather_entity.dart';
import 'package:tium/domain/repositories/weather/weather_repository.dart';

class GetUVIndex {
  GetUVIndex(this._repo);

  final LivingWeatherRepository _repo;

  Future<UVIndex> call(String areaCode) => _repo.getUVIndex(areaCode);
}
