import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
  @override
  List<Object?> get props => [];
}

class LoadWeather extends WeatherEvent {
  final String areaCode;
  const LoadWeather(this.areaCode);
  @override
  List<Object?> get props => [areaCode];
}