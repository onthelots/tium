import 'package:equatable/equatable.dart';
import 'package:tium/domain/entities/weather/weather_entity.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();
  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final UVIndex uvIndex;
  const WeatherLoaded(this.uvIndex);
  @override
  List<Object?> get props => [uvIndex];
}

class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message);
  @override
  List<Object?> get props => [message];
}
