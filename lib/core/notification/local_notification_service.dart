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
    debugPrint("🔔 알림 예약 시도: id=$id, title=$title, body=$body, scheduledDate=$scheduledDate, payload=$plantId");

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
            presentBadge: false, // 뱃지 표시 비활성화
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
