import 'package:flutter/material.dart';
import 'package:tium/presentation/home/screen/home_screen.dart';
import 'package:tium/presentation/information/screen/information_screen.dart';
import 'package:tium/presentation/main/main_screen.dart';
import 'package:tium/presentation/mypage/screen/mypage_screen.dart';
import 'package:tium/presentation/onboarding/screen/onboarding_screen.dart';
import 'package:tium/presentation/search/screen/search_screen.dart';

/// Screen Routes
class Routes {
  static const String splash = '/';
  static const String main = '/main'; // 메인
  static const String onboarding = '/onboarding'; // 온보딩

  // tab
  static const String home = '/home'; // 홈 (탭바)
  static const String information = '/information'; // 정보 (탭바)
  static const String search = '/search'; // 검색 (탭바)
  static const String mypage = '/mypage'; // 마임페이지 (탭바)

  // settings
  static const String notification = '/notification'; // 알림 설정
  static const String theme = '/theme'; // 테마설정
  static const String openSource = '/opensource'; // 오픈소스
  static const String webView = '/webView'; // 웹뷰
}

/// WebView Routes
class WebRoutes {
  static const String appSite= 'https://momentous-wallet-0f7.notion.site/1a81c3f0e003806980e5e8bd7732fa83?pvs=4'; // 앱 사이트
  static const String officialSite= 'https://dhlottery.co.kr/common.do?method=main'; // 동행복권 사이트
  static const String termsOfUse = 'https://momentous-wallet-0f7.notion.site/1ab1c3f0e0038007958ee9680d3a3256?pvs=4'; // 이용약관
  static const String privacyPolicy = 'https://momentous-wallet-0f7.notion.site/1ab1c3f0e003804a9e3ef0c151450022?pvs=4'; // 개인정보 보호
  static const String warning = 'https://momentous-wallet-0f7.notion.site/1ab1c3f0e0038032a81ec06504765a09?pvs=4'; // 주의사항
}


/// AppRouter
class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.main:
        return MaterialPageRoute(
          builder: (_) => MainScreen(),
        );
      case Routes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case Routes.information:
        return MaterialPageRoute(
          builder: (_) => const InformationScreen(),
        );
      case Routes.search:
        return MaterialPageRoute(
          builder: (_) => const SearchScreen(),
        );
      case Routes.mypage:
        return MaterialPageRoute(
          builder: (_) => const MypageScreen(),
        );
      default:
        return null;
    }
  }
}
