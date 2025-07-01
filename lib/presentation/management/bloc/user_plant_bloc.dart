import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/notification/local_notification_service.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
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

    final notificationId = event.plant.notificationId ?? event.plant.id.hashCode;

    if (event.isOn) {
      print("알림 예약을 등록했어요. 다음 물주기 알림은 알림은 ${DateTime.now().add(Duration(days: event.plant.wateringIntervalDays))}");
      await LocalNotificationService().scheduleNotification(
        id: notificationId,
        title: '물주기 알림',
        body: '${event.plant.name} 식물에 물 줄 시간이에요 💧',
        scheduledDate: DateTime.now().add(Duration(days: event.plant.wateringIntervalDays)),
        isTestMode: false,
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
    final notificationId = event.plant.notificationId ?? event.plant.id.hashCode;

    // lastWateredDate 갱신
    final updatedPlant = event.plant.copyWith(lastWateredDate: now);

    if (event.hasPermission && updatedPlant.isWateringNotificationOn) {
      print("알림 허용되어있고, 알림 켜져있으니 알림 다시 예약");
      final nextNotificationDate = now.add(Duration(days: updatedPlant.wateringIntervalDays));
      await LocalNotificationService().scheduleNotification(
        id: notificationId,
        title: '물주기 알림',
        body: '${updatedPlant.name} 식물에 물 줄 시간이에요 💧',
        scheduledDate: nextNotificationDate,
        isTestMode: false,
      );
    } else {
      print("알림 권한 없음 혹은 알림 꺼져있음, 알림 예약 안함");
      await LocalNotificationService().cancelNotification(notificationId);
    }

    final updatedPlants = currentState.user.indoorPlants.map((p) {
      return (p.id == updatedPlant.id) ? updatedPlant : p;
    }).toList();

    final updatedUser = currentState.user.copyWith(indoorPlants: updatedPlants);
    await UserPrefs.saveUser(updatedUser);
    emit(UserPlantLoaded(updatedUser));
  }
}
