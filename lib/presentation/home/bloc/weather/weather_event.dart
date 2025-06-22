abstract class WeatherEvent {}

class LoadWeather extends WeatherEvent {
  final String areaCode;
  final int nx;
  final int ny;

  LoadWeather({
    required this.areaCode,
    required this.nx,
    required this.ny,
  });
}
