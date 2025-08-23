import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tium/core/notification/local_notification_service.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/core/services/preference/notification_time_prefs.dart';
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

  /// 내 식물 추가
  Future<void> _onAddPlant(AddPlant event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;
    final now = DateTime.now();
    final notificationTime = await NotificationTimePrefs.getNotificationTime();

    DateTime nextWateringDate; // 다음 물주기 날짜

    if (kDebugMode) {
      nextWateringDate = DateTime(
        now.year,
        now.month,
        now.day,
        notificationTime.hour,
        notificationTime.minute,
      ); // 디버그용 0일 뒤
    } else {
      nextWateringDate = DateTime(
        now.year,
        now.month,
        now.day,
        notificationTime.hour,
        notificationTime.minute,
      ).add(Duration(days: event.plant.wateringIntervalDays));
    }

    final newPlant = event.plant.copyWith(nextWateringDate: nextWateringDate);
    final newPlants = [...currentState.user.indoorPlants, newPlant];
    final updatedUser = currentState.user.copyWith(indoorPlants: newPlants);

    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser));
  }

  /// 식물 정보 업데이트
  Future<void> _onUpdatePlant(UpdatePlant event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;
    final updatedPlants = currentState.user.indoorPlants.map((p) {
      if (p.id == event.updatedPlant.id) return event.updatedPlant;
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

  /// 식물 알림 설정
  Future<void> _onToggleReminder(ToggleReminder event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;
    final notificationId = event.plant.notificationId ?? (DateTime.now().millisecondsSinceEpoch.abs() % 0x7FFFFFFF);
    final notificationTime = await NotificationTimePrefs.getNotificationTime();

    UserPlant updatedPlant = event.plant;

    if (event.isOn) {
      DateTime nextWatering = updatedPlant.nextWateringDate ??
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            notificationTime.hour,
            notificationTime.minute,
          ).add(Duration(days: updatedPlant.wateringIntervalDays));

      // nextWateringDate가 이미 지난 경우 경고 및 강제 갱신
      if (nextWatering.isBefore(DateTime.now())) {
        nextWatering = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          notificationTime.hour,
          notificationTime.minute,
        ).add(Duration(days: updatedPlant.wateringIntervalDays));
      }

      updatedPlant = updatedPlant.copyWith(
        isWateringNotificationOn: true,
        notificationId: notificationId,
        nextWateringDate: nextWatering,
      );

      await LocalNotificationService().scheduleNotification(
        id: notificationId,
        title: '물주기 알림',
        body: '${updatedPlant.name} 식물에 물 줄 시간이에요 💧',
        scheduledDate: tz.TZDateTime.from(updatedPlant.nextWateringDate!, tz.local),
        plantId: updatedPlant.id,
      );
    } else {
      await LocalNotificationService().cancelNotification(notificationId);
      updatedPlant = updatedPlant.copyWith(isWateringNotificationOn: false, notificationId: null);
    }

    final updatedPlants = currentState.user.indoorPlants.map((p) {
      return p.id == updatedPlant.id ? updatedPlant : p;
    }).toList();

    final updatedUser = currentState.user.copyWith(indoorPlants: updatedPlants);
    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser));
  }

  /// 식물 물주기
  Future<void> _onWaterPlant(WaterPlant event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;
    final now = DateTime.now();
    final notificationTime = await NotificationTimePrefs.getNotificationTime();
    final notificationId = event.plant.notificationId ?? (DateTime.now().millisecondsSinceEpoch.abs() % 0x7FFFFFFF);

    DateTime nextWatering;
    if (kDebugMode) {
      nextWatering = DateTime(now.year, now.month, now.day, notificationTime.hour, notificationTime.minute);
    } else {
      nextWatering = DateTime(now.year, now.month, now.day, notificationTime.hour, notificationTime.minute)
          .add(Duration(days: event.plant.wateringIntervalDays));
    }

    UserPlant updatedPlant = event.plant.copyWith(nextWateringDate: nextWatering);

    if (event.hasPermission && updatedPlant.isWateringNotificationOn) {
      await LocalNotificationService().scheduleNotification(
        id: notificationId,
        title: '물주기 알림',
        body: '${updatedPlant.name} 식물에 물 줄 시간이에요 💧',
        scheduledDate: tz.TZDateTime.from(updatedPlant.nextWateringDate!, tz.local),
        plantId: updatedPlant.id,
      );
      updatedPlant = updatedPlant.copyWith(notificationId: notificationId);
    } else {
      await LocalNotificationService().cancelNotification(notificationId);
      updatedPlant = updatedPlant.copyWith(notificationId: null);
    }

    final updatedPlants = currentState.user.indoorPlants.map((p) {
      return p.id == updatedPlant.id ? updatedPlant : p;
    }).toList();

    final updatedUser = currentState.user.copyWith(indoorPlants: updatedPlants);
    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser));
  }

  /// 식물 알림시간 갱신
  Future<void> _onUpdateAllNotificationTimes(UpdateAllNotificationTimes event, Emitter<UserPlantState> emit) async {
    if (state is! UserPlantLoaded) return;
    final currentState = state as UserPlantLoaded;
    await LocalNotificationService().cancelAll();

    List<UserPlant> updatedPlants = [];
    for (final plant in currentState.user.indoorPlants) {
      final notificationTime = event.newTime;
      DateTime nextWatering = plant.nextWateringDate ??
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            notificationTime.hour,
            notificationTime.minute,
          ).add(Duration(days: plant.wateringIntervalDays));

      if (plant.isWateringNotificationOn) {
        final notificationId = plant.notificationId ?? (DateTime.now().millisecondsSinceEpoch.abs() % 0x7FFFFFFF);
        await LocalNotificationService().scheduleNotification(
          id: notificationId,
          title: '물주기 알림',
          body: '${plant.name} 식물에 물 줄 시간이에요 💧',
          scheduledDate: tz.TZDateTime.from(nextWatering, tz.local),
          plantId: plant.id,
        );
        updatedPlants.add(plant.copyWith(notificationId: notificationId, nextWateringDate: nextWatering));
      } else {
        updatedPlants.add(plant.copyWith(nextWateringDate: nextWatering, notificationId: null));
      }
    }

    final updatedUser = currentState.user.copyWith(indoorPlants: updatedPlants);
    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser));
  }
}
