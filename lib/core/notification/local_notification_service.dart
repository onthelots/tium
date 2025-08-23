import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:tium/components/custom_platform_alert_dialog.dart';
import 'package:tium/core/routes/route_observer_service.dart';
import 'package:tium/core/services/check_my_plant_detail.dart';
import 'package:tium/core/services/preference/notification_time_prefs.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.payload != null) {
    LocalNotificationService().navigateToPlantDetail(notificationResponse.payload!);
  }
}

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  bool _initialized = false;
  late GlobalKey<NavigatorState> _globalNavigatorKey;
  String? _initialLaunchPayload;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey, {String? initialPayload}) async {
    if (_initialized) {
      debugPrint("⚠️ LocalNotificationService 이미 초기화됨");
      return;
    }

    _globalNavigatorKey = navigatorKey;
    _initialLaunchPayload = initialPayload;

    // Android 알림 채널 생성
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'watering_channel_id',
        '물주기 알림',
        description: '식물 리마인더 알림',
        importance: Importance.max,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // 초기화 시 권한 요청 안함, 직접 권한 요청 함수에서 처리
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔔 알림 클릭됨: ${response.payload}");
        final currentRouteName = RouteObserverService().currentRouteName;

        if (response.payload != null) {
          final String plantId = response.payload!;

          if (currentRouteName == Routes.myPlantDetail) {
            final currentPlantId = CheckMyPlantDetail().currentPlantId;
            if (currentPlantId == plantId) {
              debugPrint("⚠️ 도착한 알림이 현재 보고 있는 상세 화면($plantId)과 동일하여 이동 안함");
              return;
            }
          }

          navigateToPlantDetail(plantId);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // 앱 시작 시 기존 알림 삭제 (뱃지 제거 목적)
    await flutterLocalNotificationsPlugin.cancelAll();

    _initialized = true;
    debugPrint("✅ LocalNotificationService 초기화 완료");
  }

  String? getInitialLaunchPayloadAndClear() {
    final payload = _initialLaunchPayload;
    _initialLaunchPayload = null;
    return payload;
  }

  Future<void> navigateToPlantDetail(String plantId) async {
    if (_globalNavigatorKey.currentState == null) {
      debugPrint("❌ NavigatorState is null. 네비게이션 불가");
      return;
    }

    final user = await UserPrefs.getUser();
    final plant = user?.indoorPlants.firstWhere((p) => p.id == plantId);

    if (plant != null) {
      _globalNavigatorKey.currentState!.popUntil((route) => route.isFirst);
      _globalNavigatorKey.currentState!.pushNamed(
        Routes.myPlantDetail,
        arguments: {'plant': plant},
      );
    } else {
      debugPrint("❌ Plant with ID $plantId not found.");
    }
  }

  Future<bool> requestPermissionIfNeeded(BuildContext context) async {
    if (Platform.isIOS) {
      final iosPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ??
          false;

      debugPrint("🔐 iOS 로컬 알림 권한: $granted");
      if (!granted) _showPermissionDialog(context);
      return granted;
    }

    if (Platform.isAndroid) {
      var status = await Permission.notification.request();
      if (!status.isGranted) {
        _showPermissionDialog(context);
        return false;
      }

      status = await Permission.scheduleExactAlarm.request();
      if (!status.isGranted) {
        _showExactAlarmPermissionDialog(context);
        return false;
      }
      return true;
    }

    return false;
  }

  void _showExactAlarmPermissionDialog(BuildContext context) {
    showPlatformAlertDialog(
      context: context,
      title: '정확한 알림 권한이 필요해요',
      content:
      '물주기 시간을 정확하게 알려드리기 위해 \'알람 및 리마인더\' 권한을 허용해주세요. 설정 화면으로 이동하여 권한을 활성화할 수 있습니다.',
      confirmText: '설정으로 이동',
      cancelText: '닫기',
      onConfirm: () async => openAppSettings(),
    );
  }

  Future<bool> checkPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

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

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String plantId,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // 이미 지난 시간이라면, 알림을 스케쥴하지 않음
    if (scheduledDate.isBefore(now)) {
      debugPrint("❌ 예약하려는 날짜($scheduledDate)가 현재 시간($now)보다 이전이라 알림을 등록하지 않습니다.");
      return;
    }

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
            icon: 'ic_notification',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: plantId,
      );
      debugPrint("🎉 알림 예약 성공! ID: $id, 시간: $scheduledDate");
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
