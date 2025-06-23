import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/domain/usecases/weather/weather_usecase.dart';
import 'package:tium/presentation/home/bloc/weather/weather_event.dart';
import 'package:tium/presentation/home/bloc/weather/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetUVIndex _getUV;
  final GetCurrentTemperature _getTemperature;

  WeatherBloc(this._getUV, this._getTemperature) : super(WeatherInitial()) {
    print("WeatherBloc 생성됨");

    on<LoadWeather>((event, emit) async {
      print("LoadWeather 이벤트 수신: areaCode=${event.areaCode}, nx=${event.nx}, ny=${event.ny}");
      emit(WeatherLoading());
      try {
        final uv = await _getUV(event.areaCode);
        final temp = await _getTemperature(event.nx, event.ny);

        print("자외선 지수: ${uv.value}, 기온: ${temp.temperature}°C");

        emit(WeatherLoaded(uvIndex: uv, weather: temp));
      } catch (e) {
        print("에러 발생: $e");
        emit(WeatherError(e.toString()));
      }
    });
  }
}
