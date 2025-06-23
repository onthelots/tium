import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const _themeKey = 'themeMode';
  static const _firstRunKey = 'isFirstRun';

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

  // 첫 실행 여부
  static Future<bool> getFirstRun() async =>
      (await SharedPreferences.getInstance()).getBool(_firstRunKey) ?? true;
  static Future<void> setFirstRunFalse() async =>
      (await SharedPreferences.getInstance()).setBool(_firstRunKey, false);


  // 첫 날씨 및 지역 설정
  static Future<void> setWeatherRegion(String label, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weatherRegionLabel', label);
    await prefs.setString('weatherRegionCode', code);
  }

  static Future<String?> getWeatherRegionLabel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('weatherRegionLabel');
  }

  static Future<String?> getWeatherRegionCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('weatherRegionCode');
  }
}
