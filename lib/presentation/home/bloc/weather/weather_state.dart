import 'package:tium/domain/entities/weather/weather.dart';
import 'package:tium/domain/entities/weather/uvIndex.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final UVIndex uvIndex;
  final Weather weather;

  WeatherLoaded({required this.uvIndex, required this.weather});
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}
