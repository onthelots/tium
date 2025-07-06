import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:tium/components/custom_platform_alert_dialog.dart';

import 'package:tium/core/services/preference/notification_time_prefs.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  bool _initialized = false;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// 앱 실행 시 딱 1번만 호출하는 초기화 (알림 채널 생성 및 플러그인 초기화)
  Future<void> init() async {
    if (_initialized) {
      debugPrint("⚠️ LocalNotificationService 이미 초기화됨");
      return;
    }

    debugPrint("🔧 LocalNotificationService 초기화 시작");

    // 채널 생성
    const channel = AndroidNotificationChannel(
      'watering_channel_id',
      '물주기 알림',
      description: '식물 리마인더 알림',
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔔 알림 클릭됨: ${response.payload}");
      },
    );

    _initialized = true;
    debugPrint("✅ LocalNotificationService 초기화 완료");
  }


  /// 알림 권한 요청 및 확인 (사용자가 알림 켤 때만 호출)
  Future<bool> requestPermissionIfNeeded(BuildContext context) async {
    // init 호출하여 초기화 보장 (중복 호출 시 바로 리턴)
    await init();

    if (Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint("🔐 iOS 권한 상태: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.authorized) return true;

      _showPermissionDialog(context);
      return false;
    }

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;

      final result = await Permission.notification.request();
      if (result.isGranted) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission(); // 추가
        return true;
      }

      _showPermissionDialog(context);
      return false;
    }

    return false; // 기타 플랫폼
  }

  /// 알림 권한 상태 확인 (권한 요청 없이)
  Future<bool> checkPermission() async {
    await init();

    if (Platform.isIOS) {
      final settings = await _messaging.getNotificationSettings();
      debugPrint("🔍 iOS 권한 상태 확인: ${settings.authorizationStatus}");
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      debugPrint("🔍 Android 권한 상태 확인: $status");
      return status.isGranted;
    }

    return false; // 기타 플랫폼
  }

  /// 권한 안내 다이얼로그 (설정 이동 유도)
  void _showPermissionDialog(BuildContext context) {
    showPlatformAlertDialog(
      context: context,
      title: '알림 권한이 필요해요',
      content: '식물의 물주기 알림을 받으려면 알림 권한을 허용해주세요.',
      confirmText: '설정으로 이동',
      cancelText: '닫기',
      onConfirm: () async => openAppSettings(),
    );
  }

  /// 알림 예약
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int days,
    int? hour,
    int? minute,
  }) async {
    debugPrint('현재 tz.local: ${tz.local}');
    debugPrint('tz.local timezone name: ${tz.local.name}');

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate;

    // 설정된 알림 시간 불러오기 (기본값 12:00)
    final notificationTime = await NotificationTimePrefs.getNotificationTime();
    final targetHour = hour ?? notificationTime.hour;
    final targetMinute = minute ?? notificationTime.minute;

    if (kDebugMode) {
      // 디버그 모드: 릴리즈와 동일한 로직으로, 현재 시간 기준 10초 뒤로 예약
      final nowIn10Seconds = now.add(const Duration(seconds: 10));
      scheduledDate = tz.TZDateTime(
        tz.local,
        nowIn10Seconds.year,
        nowIn10Seconds.month,
        nowIn10Seconds.day,
        nowIn10Seconds.hour,
        nowIn10Seconds.minute,
        nowIn10Seconds.second,
      );
    } else {
      // 릴리즈 모드: D-day(days) 후의 날짜, 설정된 시간(targetHour:targetMinute)으로 예약
      scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day + days, targetHour, targetMinute);
    }

    // 예약하려는 시간이 이미 과거인지 최종 확인
    if (scheduledDate.isBefore(now)) {
      debugPrint("❌ 알림 예약 실패: 계산된 예약 시간($scheduledDate)이 현재 시간($now)보다 과거입니다. 하루 뒤로 조정합니다.");
      // 만약 계산된 시간이 과거이면 (예: 정오가 이미 지났는데 days=0인 경우), 다음 날로 설정
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('🔔 예약 시간 (timeZoneName): ${scheduledDate.timeZoneName}');
    debugPrint("🔔 알림 예약 시도: id=$id, title=$title, body=$body, scheduledDate=$scheduledDate");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'watering_channel_id',
            '물주기 알림',
            channelDescription: '식물 리마인더 알림',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            ticker: 'ticker',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint("🎉 알림 예약 성공!");
    } catch (e, stack) {
      debugPrint("❌ 알림 예약 실패: $e");
      debugPrint("$stack");
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
