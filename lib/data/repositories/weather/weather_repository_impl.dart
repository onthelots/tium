import 'package:tium/data/datasources/weather/weather_remote_datasource.dart';
import 'package:tium/domain/entities/weather/temperature.dart';
import 'package:tium/domain/entities/weather/uvIndex.dart';
import 'package:tium/domain/repositories/weather/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._remote);

  final WeatherRemoteDataSource _remote;

  // ───────────────────────── 기온
  @override
  Future<Temperature> getTemperature(int nx, int ny) async {
    final dto = await _remote.fetchTemperature(nx: nx, ny: ny);
    return Temperature(baseTime: dto.baseDateTime, value: dto.value);
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
