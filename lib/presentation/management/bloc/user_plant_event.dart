import 'package:flutter/material.dart';
import 'package:tium/data/models/user/user_model.dart';

abstract class UserPlantEvent {}

class LoadUserPlant extends UserPlantEvent {}

/// 식물 등록
class AddPlant extends UserPlantEvent {
  final UserPlant plant;
  AddPlant(this.plant);
}

/// 식물 정보 업데이트
class UpdatePlant extends UserPlantEvent {
  final UserPlant updatedPlant;
  UpdatePlant(this.updatedPlant);
}

/// 식물 삭제
class DeletePlant extends UserPlantEvent {
  final UserPlant plant;
  DeletePlant(this.plant);
}

/// 물주기 스위치 설정
class ToggleReminder extends UserPlantEvent {
  final UserPlant plant;
  final bool isOn;
  ToggleReminder(this.plant, this.isOn);
}

/// 물주기 버튼 Click! (재 설정)
class WaterPlant extends UserPlantEvent {
  final UserPlant plant;
  final bool hasPermission;

  WaterPlant(this.plant, {this.hasPermission = false});
}

/// 모든 알림 시간 업데이트
class UpdateAllNotificationTimes extends UserPlantEvent {
  final TimeOfDay newTime;
  UpdateAllNotificationTimes(this.newTime);
}
