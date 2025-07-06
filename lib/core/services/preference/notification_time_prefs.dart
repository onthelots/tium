import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationTimePrefs {
  static const _notificationHourKey = 'notification_hour';
  static const _notificationMinuteKey = 'notification_minute';

  /// 알림 시간 저장
  static Future<void> saveNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationHourKey, time.hour);
    await prefs.setInt(_notificationMinuteKey, time.minute);
  }

  /// 저장된 알림 시간 불러오기
  /// 저장된 값이 없으면 기본값으로 정오(12:00)를 반환합니다.
  static Future<TimeOfDay> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_notificationHourKey) ?? 12; // 기본값: 12시 (정오)
    final minute = prefs.getInt(_notificationMinuteKey) ?? 0; // 기본값: 0분
    debugPrint('Loaded notification time: $hour:$minute');
    return TimeOfDay(hour: hour, minute: minute);
  }
}
