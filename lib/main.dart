import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'core/di/locator.dart';
import 'core/routes/routes.dart';
import 'core/services/shared_preferences_helper.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/main/bloc/theme_bloc/theme_bloc.dart';
import 'presentation/main/bloc/theme_bloc/theme_event.dart';
import 'presentation/main/bloc/theme_bloc/theme_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  // 앱 구동여부 확인
  final bool isFirstRun = await SharedPreferencesHelper.getFirstRunState();
  final String initialRoute = isFirstRun ? Routes.onboarding : Routes.main;

  // Firebase, DI(Locator), Hive를 병렬로 초기화
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    setupLocator(),
  ]);

  // run
  Future.delayed(Duration(seconds: 2), () {
    runApp(MyApp(initialRoute: initialRoute));
  });
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
            initialRoute: widget.initialRoute,
            onGenerateRoute: _router.onGenerateRoute,
          );
        },
      ),
    );
  }
}