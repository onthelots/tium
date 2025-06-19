import 'package:tium/data/datasources/weather/weather_remote_datasource.dart';
import 'package:tium/domain/entities/weather/weather_entity.dart';
import 'package:tium/domain/repositories/weather/weather_repository.dart';

class LivingWeatherRepositoryImpl implements LivingWeatherRepository {
  LivingWeatherRepositoryImpl(this._remote);

  final LivingWeatherRemoteDataSource _remote;

  @override
  Future<UVIndex> getUVIndex(String areaCode) async {
    final dto = await _remote.fetchUVIndex(areaCode: areaCode);
    return UVIndex(
      publishTime: DateTime.parse(dto.publishTime),
      value: dto.uvValue,
    );
  }
}