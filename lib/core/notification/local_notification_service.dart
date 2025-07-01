import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:tium/components/custom_platform_alert_dialog.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  bool _initialized = false;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// 초기화 (앱 시작 시 호출하지 말고, 필요 시에만 호출)
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    // Android 채널 생성
    const channel = AndroidNotificationChannel(
      'watering_channel_id',
      '물주기 알림',
      description: '식물 리마인더 알림',
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 플러터 알림 초기화
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false, // 직접 요청하므로 false
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
  }

  /// 권한 요청 및 체크
  Future<bool> requestPermissionIfNeeded(BuildContext context) async {
    await init(); // 필요 시 초기화

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
      debugPrint("🔐 Android 권한 상태: $status");

      if (status.isGranted) return true;

      final result = await Permission.notification.request();
      debugPrint("🔁 Android 재요청 결과: $result");

      if (result.isGranted) return true;

      _showPermissionDialog(context);
      return false;
    }

    return false; // 기타 플랫폼
  }

  // 권한 허용여부 확인
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


  /// 설정 다이얼로그
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
    required DateTime scheduledDate,
    bool isTestMode = false, // 추가
  }) async {
    final tz.TZDateTime tzDateTime;

    if (isTestMode) {
      // 테스트 모드: 현재 시간 + 10초
      final testTime = DateTime.now().add(const Duration(seconds: 10));
      tzDateTime = tz.TZDateTime.from(testTime, tz.local);
      debugPrint('🧪 [TEST MODE] 알림 예약: $tzDateTime');
    } else {
      // 실제 알림은 18:00에 예약
      final scheduledTimeAt6PM = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        18,
      );
      tzDateTime = tz.TZDateTime.from(scheduledTimeAt6PM, tz.local);
      debugPrint('✅ [PROD MODE] 알림 예약: $tzDateTime');
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'watering_channel_id',
          '물주기 알림',
          channelDescription: '식물 리마인더 알림',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: isTestMode ? null : DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
