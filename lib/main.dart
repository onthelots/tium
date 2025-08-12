import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:tium/core/app_info/app_info_cubit.dart';
import 'package:tium/core/notification/local_notification_service.dart';
import 'package:tium/core/routes/route_observer_service.dart';
import 'package:tium/presentation/home/bloc/juso_search/juso_search_cubit.dart';
import 'package:tium/presentation/home/bloc/location/location_search_bloc.dart';
import 'package:tium/presentation/home/bloc/user_type/user_type_cubit.dart';
import 'package:tium/presentation/home/screen/weather/juso_search_screen.dart';
import 'package:tium/presentation/main/bloc/bottom_nav_bloc/bottom_nav_bloc.dart';
import 'package:tium/presentation/plant/bloc/plant_data/plant_data_bloc.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_bloc.dart';
import 'core/di/locator.dart';
import 'core/routes/routes.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/home/bloc/plant_section/plant_section_bloc.dart';
import 'presentation/home/bloc/plant_section_list/plant_section_list_bloc.dart';
import 'presentation/home/bloc/weather/weather_bloc.dart';
import 'presentation/home/screen/home_screen.dart';
import 'presentation/main/bloc/theme_bloc/theme_bloc.dart';
import 'presentation/main/bloc/theme_bloc/theme_event.dart';
import 'presentation/main/bloc/theme_bloc/theme_state.dart';
import 'presentation/management/bloc/user_plant_bloc.dart';
import 'presentation/management/bloc/user_plant_event.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 터미네이터 상태 변수
String? initialPlantIdFromNotification;

Future<void> main() async {
  // 위젯 바인딩 및 스플래시 유지
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 환경변수
  await dotenv.load();
  final supabaseUrl = dotenv.env['SUPABASE_URL']!; // Supabase url
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY']!;  // Supabase anon key
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey); // Supabase 초기화

  // 앱이 알림을 통해 시작되었는지 확인
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    print("앱 백그라운드 및 종료 상태에서 알림이 도착했나요? ${initialPlantIdFromNotification}");
    initialPlantIdFromNotification = notificationAppLaunchDetails!.notificationResponse?.payload;
  }

  // 초기화 로직
  await initTimeZone(); // 시간대 설정
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // firebase 초기화
  await setupLocator(); // locator 주입

  // 초기화면 (Splash)
  final String initialRoute = Routes.splash;

  // 초기화가 모두 끝난 후 스플래시 제거
  FlutterNativeSplash.remove();

  runApp(MyApp(initialRoute: initialRoute, initialPayload: initialPlantIdFromNotification));
}

Future<void> initTimeZone() async {
  tz_data.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  debugPrint('Local timezone set to $timeZoneName');
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  final String? initialPayload; // Add initialPayload

  MyApp({super.key, required this.initialRoute, this.initialPayload}); // Update constructor

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _router = AppRouter();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final RouteObserverService routeObserver = RouteObserverService();

  @override
  void initState() {
    super.initState();
        LocalNotificationService().init(navigatorKey, initialPayload: initialPlantIdFromNotification);
    initialPlantIdFromNotification = null; // 사용 후 즉시 초기화
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
          ThemeBloc()
            ..add(ThemeInitialEvent()), // 앱 실행 시 테마 초기화
        ),

        BlocProvider(
          create: (context) => BottomNavBloc()
        ),

        // 전역 식물 데이터 Bloc
        BlocProvider(
          create: (_) => locator<PlantDataBloc>()..add(LoadAllPlantsEvent()),
        ),

        // 날씨 정보 Bloc
        BlocProvider(
          create: (_) => locator<WeatherBloc>(),
          child: HomeScreen(),
        ),

        // 위치 정보 Bloc
        BlocProvider(
          create: (_) => locator<LocationBloc>(),
          child: HomeScreen(),
        ),

        // 추천 식물 리스트
        BlocProvider(
          create: (_) => locator<RecommendationSectionBloc>(),
          child: HomeScreen(),
        ),

        // 식물 리스트
        BlocProvider(
          create: (_) => locator<FilteredPlantListBloc>(),
          child: HomeScreen(),
        ),

        // 주소 찾기
        BlocProvider(
          create: (_) => locator<JusoSearchCubit>(),
          child: JusoSearchScreen(),
        ),

        // 내 유형 정보 불러오기
        BlocProvider(
          create: (_) => locator<UserTypeCubit>(),
          child: HomeScreen(),
        ),

        // 검색창
        BlocProvider(
          create: (_) => locator<SearchBloc>(),
          child: HomeScreen(),
        ),

        // 앱 버전
        BlocProvider(
          create: (context) =>
          AppInfoCubit()
            ..fetchAppVersion(),
        ),
        BlocProvider(
          create: (context) =>
          UserPlantBloc()
            ..add(LoadUserPlant()),
        ),
      ],

      // 갱신 - listener
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeMode =
          (state is ThemeInitial) ? state.themeMode : ThemeMode.system;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            navigatorKey: navigatorKey,
            navigatorObservers: [routeObserver],
            initialRoute: widget.initialRoute,
            onGenerateRoute: _router.onGenerateRoute,

            builder: (context, child) {
              final brightness = Theme.of(context).brightness;
              final overlayStyle = brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark;

              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}