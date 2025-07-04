import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:tium/core/app_info/app_info_cubit.dart';
import 'package:tium/core/notification/local_notification_service.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/home/bloc/juso_search/juso_search_cubit.dart';
import 'package:tium/presentation/home/bloc/location/location_search_bloc.dart';
import 'package:tium/presentation/home/screen/weather/juso_search_screen.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_bloc.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_event.dart';
import 'core/di/locator.dart';
import 'core/routes/routes.dart';
import 'core/services/shared_preferences_helper.dart';
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

Future<void> main() async {
  // 위젯 바인딩 및 스플래시 유지
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 초기화 로직
  await initTimeZone();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService().init();
  await setupLocator();

  final isFirstRun = await SharedPreferencesHelper.getFirstRun();
  final String initialRoute = isFirstRun ? Routes.intro : Routes.main;

  // 초기화가 모두 끝난 후 스플래시 제거
  FlutterNativeSplash.remove();

  runApp(MyApp(initialRoute: initialRoute));
}

Future<void> initTimeZone() async {
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _router = AppRouter();
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc()..add(ThemeInitialEvent()), // 앱 실행 시 테마 초기화
        ),
        BlocProvider(
          create: (_) => locator<WeatherBloc>(),
          child: HomeScreen(),  // bloc은 HomeScreen 내부에서 add 호출됨
        ),
        BlocProvider(
          create: (_) => locator<LocationBloc>(),
          child: HomeScreen(),  // bloc은 HomeScreen 내부에서 add 호출됨
        ),
        BlocProvider(
          create: (_) => locator<RecommendationSectionBloc>(),
          child: HomeScreen(),  // bloc은 HomeScreen 내부에서 add 호출됨
        ),
        BlocProvider(
          create: (_) => locator<FilteredPlantListBloc>(),
          child: HomeScreen(),  // bloc은 HomeScreen 내부에서 add 호출됨
        ),
        BlocProvider(
          create: (_) => locator<JusoSearchCubit>(),
          child: JusoSearchScreen(),  // bloc은 HomeScreen 내부에서 add 호출됨
        ),
        BlocProvider(
          create: (_) => locator<SearchBloc>(),
          child: HomeScreen(),
        ),
        // version
        BlocProvider(
          create: (context) => AppInfoCubit()..fetchAppVersion(),
        ),
        BlocProvider(
          create: (context) => UserPlantBloc()..add(LoadUserPlant()),
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

            // 테스트 시, intro로 설정
            initialRoute: widget.initialRoute,
            onGenerateRoute: _router.onGenerateRoute,
          );
        },
      ),
    );
  }
}