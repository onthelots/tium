import 'package:flutter/material.dart';

class CheckMyPlantDetail {
  static final CheckMyPlantDetail _instance = CheckMyPlantDetail._internal();
  factory CheckMyPlantDetail() => _instance;
  CheckMyPlantDetail._internal();

  String? _currentPlantId;

  void setCurrentPlantId(String? plantId) {
    _currentPlantId = plantId;
    debugPrint("🌱 현재 보고 있는 plantId 설정됨: $_currentPlantId");
  }

  String? get currentPlantId => _currentPlantId;

  void clear() {
    _currentPlantId = null;
  }
}
