import 'package:flutter/material.dart';
import 'package:grodi/presentation/main/main.dart';

/// Screen Routes
class Routes {
  static const String splash = '/';
  static const String main = '/main'; // 메인

  // notice
  static const String notice = '/notice'; // 공지사항

  // introduce
  static const String introduce = '/introduce'; // 소개페이지

  // tab
  static const String home = '/home'; // 홈 (탭바)
  static const String weekly = '/weekly'; // 번호기록 (탭바)
  static const String mypage = '/mypage'; // 마임페이지 (탭바)

  // round list
  static const String allround = '/allround'; // 번호기록 (탭바)

  // statics
  static const String stats = '/stats'; // 회차별 통계

  // latest round result
  static const String latestRoundResult = '/latestRoundResult'; // 최근 회차 결과

  // number generate
  static const String dailyQuestion = '/dailyQuestion'; // 번호 생성 퀴즈
  static const String recommendation = '/recommendation'; // 번호 생성 결과 (AI 추천결과)

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
      // case Routes.home:
      //   return MaterialPageRoute(
      //     builder: (_) => const HomeScreen(),
      //   );
      default:
        return null;
    }
  }
}
