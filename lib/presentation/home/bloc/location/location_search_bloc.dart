import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/domain/usecases/location/location_usecase.dart';
import 'package:tium/presentation/home/bloc/location/location_search_event.dart';
import 'package:tium/presentation/home/bloc/location/location_search_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final FindLocationByAddress findByAddress;
  final FindLocationByLatLng findByLatLng;

  LocationBloc({
    required this.findByAddress,
    required this.findByLatLng,
  }) : super(LocationInitial()) {
    on<LocationByAddressRequested>((event, emit) async {
      emit(LocationLoadInProgress());
      try {
        final location = await findByAddress(event.address);
        emit(LocationLoadSuccess(location));
      } catch (e) {
        emit(LocationLoadFailure('주소 위치를 찾는 중 오류가 발생했습니다.'));
      }
    });

    on<LocationByLatLngRequested>((event, emit) async {
      emit(LocationLoadInProgress());
      try {
        final location = await findByLatLng(event.lat, event.lng);
        emit(LocationLoadSuccess(location));
      } catch (e, stack) {
        // ⇢ 로그에 전체 에러와 스택 출력
        debugPrint('❌ Location error: $e');
        debugPrintStack(stackTrace: stack);
        emit(LocationLoadFailure('좌표 위치를 찾는 중 오류가 발생했습니다.'));
      }
    });
  }
}
