import 'package:tium/data/datasources/weather/weather_remote_datasource.dart';
import 'package:tium/domain/entities/weather/weather.dart';
import 'package:tium/domain/entities/weather/uvIndex.dart';
import 'package:tium/domain/repositories/weather/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._remote);

  final WeatherRemoteDataSource _remote;

  @override
  Future<Weather> getTemperature(int nx, int ny) async {
    final dto = await _remote.fetchWeather(nx: nx, ny: ny);
    return Weather(baseTime: dto.baseDateTime, temperature: dto.temperature, condition: dto.conditionText);
  }

  @override
  Future<UVIndex> getUVIndex(String areaNo) async {
    final dto = await _remote.fetchUVIndex(areaNo: areaNo);
    final item = dto.items.first;
    final base = _toDate(item.date);        // yyyyMMddHH → DateTime
    final uv = int.parse('${item.hourlyUV['h0'] ?? '0'}');
    return UVIndex(publishTime: base, value: uv);
  }

  DateTime _toDate(String s) => DateTime(
    int.parse(s.substring(0,4)),
    int.parse(s.substring(4,6)),
    int.parse(s.substring(6,8)),
    int.parse(s.substring(8,10)),
  );
}
