import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const _themeKey = 'themeMode';

  // 테마 모드 저장
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_themeKey, mode.index);  // ThemeMode의 enum 값은 int로 저장됩니다.
  }

  // 테마 모드 가져오기
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final int? themeIndex = prefs.getInt(_themeKey);  // 저장된 값 읽기
    if (themeIndex != null) {
      return ThemeMode.values[themeIndex];
    } else {
      // 값이 없으면 기본값인 ThemeMode.system 반환
      return ThemeMode.system;
    }
  }

  // 앱 구동여부 확인
  static Future<bool> getFirstRunState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? isFirstRun = prefs.getBool('isFirstRun');
    return isFirstRun ?? true;
  }

  // 앱 첫 구동여부 false로 설정할 것
  static Future<void> setFirstRunStateToFalse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
  }

  // 면책사항 확인 여부 확인
  static Future<bool> getWaringCheckState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? isWaringCheck = prefs.getBool('isWaringCheck');
    return isWaringCheck ?? false;
  }

  // 앱 첫 구동여부 false로 설정할 것
  static Future<void> setWaringCheckStateToTrue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isWaringCheck', true);
  }
}
