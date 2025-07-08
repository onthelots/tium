import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tium/core/notification/local_notification_service.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/management/bloc/user_plant_event.dart';
import 'package:tium/presentation/management/bloc/user_plant_state.dart';

class UserPlantBloc extends Bloc<UserPlantEvent, UserPlantState> {
  UserPlantBloc() : super(UserPlantInitial()) {
    on<LoadUserPlant>(_onLoadUser);
    on<AddPlant>(_onAddPlant);
    on<UpdatePlant>(_onUpdatePlant);
    on<DeletePlant>(_onDeletePlant);
    on<ToggleReminder>(_onToggleReminder);
    on<WaterPlant>(_onWaterPlant);
    on<UpdateAllNotificationTimes>(_onUpdateAllNotificationTimes);
  }

  /// 유저 정보 불러오기
  Future<void> _onLoadUser(LoadUserPlant event, Emitter<UserPlantState> emit) async {
    emit(UserPlantLoading());
    try {
      final user = await UserPrefs.getUser();
      if (user == null) throw Exception('유저 정보를 불러올 수 없습니다.');
      emit(UserPlantLoaded(user));
    } catch (e) {
      emit(UserPlantError(e.toString()));
    }
  }

  /// 식물 등록하기
  Future<void> _onAddPlant(AddPlant event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;
    final newPlants = [...currentState.user.indoorPlants, event.plant];
    final updatedUser = currentState.user.copyWith(indoorPlants: newPlants);
    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser));
  }

  /// 식물 정보 업데이트
  Future<void> _onUpdatePlant(UpdatePlant event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;
    final updatedPlants = currentState.user.indoorPlants.map((p) {
      if (p.id == event.updatedPlant.id) {
        return event.updatedPlant;
      }
      return p;
    }).toList();
    final updatedUser = currentState.user.copyWith(indoorPlants: updatedPlants);
    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser));
  }

  /// 식물 삭제
  Future<void> _onDeletePlant(DeletePlant event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;

    if (event.plant.isWateringNotificationOn && event.plant.notificationId != null) {
      await LocalNotificationService().cancelNotification(event.plant.notificationId!);
    }

    final filteredPlants = currentState.user.indoorPlants.where((p) => p.id != event.plant.id).toList();
    final updatedUser = currentState.user.copyWith(indoorPlants: filteredPlants);
    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser));
  }

  /// 식물 알림 등록여부 스위칭
  Future<void> _onToggleReminder(ToggleReminder event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;

    final notificationId = event.plant.notificationId ?? (DateTime.now().millisecondsSinceEpoch.abs() % 0x7FFFFFFF);

    if (event.isOn) {
      await LocalNotificationService().scheduleNotification(
        id: notificationId,
        title: '물주기 알림',
        body: '${event.plant.name} 식물에 물 줄 시간이에요 💧',
        days: event.plant.wateringIntervalDays,
        plantId: event.plant.id,
      );
    } else {
      await LocalNotificationService().cancelNotification(notificationId);
    }

    final updatedPlants = currentState.user.indoorPlants.map((p) {
      if (p.id == event.plant.id) {
        return p.copyWith(
          isWateringNotificationOn: event.isOn,
          notificationId: event.isOn ? notificationId : null,
        );
      }
      return p;
    }).toList();

    final updatedUser = currentState.user.copyWith(indoorPlants: updatedPlants);
    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser));
  }

  /// 식물 물주기 (!! 알림 재 설정)
  Future<void> _onWaterPlant(WaterPlant event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;

    final now = DateTime.now();
    final notificationId = event.plant.notificationId ?? (DateTime.now().millisecondsSinceEpoch.abs() % 0x7FFFFFFF);

    // lastWateredDate 갱신
    UserPlant updatedPlant = event.plant.copyWith(lastWateredDate: now);

    if (event.hasPermission && updatedPlant.isWateringNotificationOn) {
      print("알림 허용되어있고, 알림 켜져있으니 알림 다시 예약");
      await LocalNotificationService().scheduleNotification(
        id: notificationId,
        title: '물주기 알림',
        body: '${updatedPlant.name} 식물에 물 줄 시간이에요 💧',
        days: updatedPlant.wateringIntervalDays,
        plantId: updatedPlant.id,
      );
      // 알림이 성공적으로 예약되었으므로 notificationId를 updatedPlant에 저장
      updatedPlant = updatedPlant.copyWith(notificationId: notificationId);
    } else {
      print("알림 권한 없음 혹은 알림 꺼져있음, 알림 예약 안함");
      await LocalNotificationService().cancelNotification(notificationId);
      updatedPlant = updatedPlant.copyWith(notificationId: null);
    }

    final updatedPlants = currentState.user.indoorPlants.map((p) {
      return (p.id == updatedPlant.id) ? updatedPlant : p;
    }).toList();

    final updatedUser = currentState.user.copyWith(indoorPlants: updatedPlants);
    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser));
  }

  /// 모든 알림 시간 업데이트 및 재설정
  Future<void> _onUpdateAllNotificationTimes(UpdateAllNotificationTimes event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;

    // 1. 기존 알림 모두 취소
    await LocalNotificationService().cancelAll();

    List<UserPlant> updatedPlants = [];

    // 2. 모든 식물에 대해 알림 재설정
    for (final plant in currentState.user.indoorPlants) {
      if (plant.isWateringNotificationOn) {
            final notificationId = plant.notificationId ?? (DateTime.now().millisecondsSinceEpoch.abs() % 0x7FFFFFFF);
        await LocalNotificationService().scheduleNotification(
          id: notificationId,
          title: '물주기 알림',
          body: '${plant.name} 식물에 물 줄 시간이에요 💧',
          days: plant.wateringIntervalDays,
          hour: event.newTime.hour,
          minute: event.newTime.minute,
          plantId: plant.id,
        );
        // 알림이 성공적으로 예약되었으므로 notificationId를 plant에 저장
        updatedPlants.add(plant.copyWith(notificationId: notificationId));
      } else {
        // 알림이 꺼져있으면 notificationId를 null로 설정
        updatedPlants.add(plant.copyWith(notificationId: null));
      }
    }
    final updatedUser = currentState.user.copyWith(indoorPlants: updatedPlants);
    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser)); // 상태 업데이트
  }
}
