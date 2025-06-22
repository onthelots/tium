import 'package:tium/domain/entities/weather/temperature.dart';
import 'package:tium/domain/entities/weather/uvIndex.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final UVIndex uvIndex;
  final Temperature temperature;

  WeatherLoaded({required this.uvIndex, required this.temperature});
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}
