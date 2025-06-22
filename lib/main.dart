import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tium/presentation/home/bloc/juso_search/juso_search_cubit.dart';
import 'package:tium/presentation/home/bloc/location/location_search_bloc.dart';
import 'package:tium/presentation/home/screen/juso_search_screen.dart';
import 'core/di/locator.dart';
import 'core/routes/routes.dart';
import 'core/services/shared_preferences_helper.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/home/bloc/weather/weather_bloc.dart';
import 'presentation/home/bloc/weather/weather_event.dart';
import 'presentation/home/screen/home_screen.dart';
import 'presentation/main/bloc/theme_bloc/theme_bloc.dart';
import 'presentation/main/bloc/theme_bloc/theme_event.dart';
import 'presentation/main/bloc/theme_bloc/theme_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupLocator();

  final isFirstRun = await SharedPreferencesHelper.getFirstRun();

  final String initialRoute = isFirstRun
      ? Routes.intro
      : Routes.main;

  runApp(MyApp(initialRoute: initialRoute));
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
          create: (_) => locator<JusoSearchCubit>(),
          child: JusoSearchScreen(),  // bloc은 HomeScreen 내부에서 add 호출됨
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