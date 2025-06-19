import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/domain/usecases/weather/weather_usecase.dart';
import 'package:tium/presentation/home/bloc/weather/weather_event.dart';
import 'package:tium/presentation/home/bloc/weather/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc(this._getUV) : super(WeatherInitial()) {
    print("WeatherBloc 생성됨");  // <== 여기에 찍어보기
    on<LoadWeather>((event, emit) async {
      print("LoadWeather 이벤트 수신: areaCode=${event.areaCode}");  // <== 이벤트 받는지 확인
      emit(WeatherLoading());
      try {
        final uv = await _getUV(event.areaCode);
        print("자외선 지수 : ${uv.value}");
        emit(WeatherLoaded(uv));
      } catch (e) {
        print("에러 발생: $e");  // <== 에러 메시지 출력
        emit(WeatherError(e.toString()));
      }
    });
  }

  final GetUVIndex _getUV;
}