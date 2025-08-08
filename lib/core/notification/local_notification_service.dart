import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:tium/components/custom_platform_alert_dialog.dart';
import 'package:tium/core/routes/route_observer_service.dart';
import 'package:tium/core/services/check_my_plant_detail.dart';
import 'package:tium/core/services/preference/notification_time_prefs.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/data/models/user/user_model.dart';


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
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late GlobalKey<NavigatorState> _globalNavigatorKey; // GlobalKey로 변경
  String? _initialLaunchPayload; // 초기 알림 페이로드 저장 필드

  /// 앱 실행 시 딱 1번만 호출하는 초기화 (알림 채널 생성 및 플러그인 초기화)
  Future<void> init(GlobalKey<NavigatorState> navigatorKey, {String? initialPayload}) async {
    if (_initialized) {
      debugPrint("⚠️ LocalNotificationService 이미 초기화됨");
      return;
    }

    _globalNavigatorKey = navigatorKey; // GlobalKey 할당
    _initialLaunchPayload = initialPayload; // 초기 페이로드 저장

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
        final currentRouteName = RouteObserverService().currentRouteName;

        if (response.payload != null) {
          final String plantId = response.payload!;

          // plant id를 비교해서 navigate 로직을 수행하지 않도록 함
          if (currentRouteName == Routes.myPlantDetail) {
            final currentPlantId = CheckMyPlantDetail().currentPlantId;
            if (currentPlantId == plantId) {
              debugPrint("⚠️ 도착한 알림이 지금 보고있는 식물 상세 화면($plantId)이므로, 이동하지 않습니다.");
              return;
            }
          }

          navigateToPlantDetail(plantId);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // 기존 알림 모두 삭제 (뱃지 제거 목적)
    await flutterLocalNotificationsPlugin.cancelAll();

    _initialized = true;
    debugPrint("✅ LocalNotificationService 초기화 완료");
  }

  /// 앱 초기 실행 시 알림 페이로드를 처리하여 화면 이동
  String? getInitialLaunchPayloadAndClear() {
    final payload = _initialLaunchPayload;
    _initialLaunchPayload = null; // 사용 후 초기화
    return payload;
  }

  /// 알림 클릭 시 식물 상세 화면으로 이동
  Future<void> navigateToPlantDetail(String plantId) async {
    if (_globalNavigatorKey.currentState == null) {
      debugPrint("❌ NavigatorState is null. Cannot navigate.");
      return;
    }

    // UserPlant 객체를 로드
    final user = await UserPrefs.getUser();
    final plant = user?.indoorPlants.firstWhere((p) => p.id == plantId);

    if (plant != null) {
      // 앱의 최상위 라우트로 이동 (모든 스택 제거)
      _globalNavigatorKey.currentState!.popUntil((route) => route.isFirst);

      // 상세 화면으로 푸시
      _globalNavigatorKey.currentState!.pushNamed(
        Routes.myPlantDetail,
        arguments: {'plant': plant},
      );
    } else {
      debugPrint("❌ Plant with ID $plantId not found.");
    }
  }


  /// 알림 권한 요청 및 확인 (사용자가 알림 켤 때만 호출)
  Future<bool> requestPermissionIfNeeded(BuildContext context) async {
    if (Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: false, // 뱃지 권한 비활성화
        sound: true,
      );
      debugPrint("🔐 iOS 권한 상태: ${settings.authorizationStatus}");
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        return true;
      }
      _showPermissionDialog(context);
      return false;
    }

    if (Platform.isAndroid) {
      // 1. 일반 알림 권한 요청
      var status = await Permission.notification.request();
      if (!status.isGranted) {
        _showPermissionDialog(context);
        return false;
      }

      // 2. 정확한 알람 권한 요청 (Android 12 이상)
      status = await Permission.scheduleExactAlarm.request();
      if (!status.isGranted) {
        _showExactAlarmPermissionDialog(context); // 별도의 안내 다이얼로그 표시
        return false;
      }
      return true;
    }
    return false; // 기타 플랫폼
  }

  /// 정확한 알람 권한 안내 다이얼로그
  void _showExactAlarmPermissionDialog(BuildContext context) {
    showPlatformAlertDialog(
      context: context,
      title: '정확한 알림 권한이 필요해요',
      content: '물주기 시간을 정확하게 알려드리기 위해 \'알람 및 리마인더\' 권한을 허용해주세요. 설정 화면으로 이동하여 권한을 활성화할 수 있습니다.',
      confirmText: '설정으로 이동',
      cancelText: '닫기',
      onConfirm: () async => openAppSettings(),
    );
  }

  /// 알림 권한 상태 확인 (권한 요청 없이)
  Future<bool> checkPermission() async {
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
    required String plantId, // plantId 추가
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
      final debugTargetDay = now.add(Duration(days: 0));
      scheduledDate = tz.TZDateTime(
        tz.local,
        debugTargetDay.year,
        debugTargetDay.month,
        debugTargetDay.day,
        targetHour,
        targetMinute,
      );
    } else {
      final targetDay = now.add(Duration(days: days));
      scheduledDate = tz.TZDateTime(
        tz.local,
        targetDay.year,
        targetDay.month,
        targetDay.day,
        targetHour,
        targetMinute,
      );
    }

    // 예약하려는 시간이 이미 과거인지 최종 확인
    if (scheduledDate.isBefore(now)) {
      debugPrint("❌ 알림 예약 실패: 계산된 예약 시간($scheduledDate)이 현재 시간($now)보다 과거입니다. 하루 뒤로 조정합니다.");
      scheduledDate = scheduledDate.add(const Duration(days: 1));
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
              icon: 'ic_notification'
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false, // 뱃지 표시 비활성화
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: plantId, // payload 설정
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
