import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/di/locator.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/home/screen/home_screen.dart';
import 'package:tium/presentation/home/screen/plant_section/plant_section_list_screen.dart';
import 'package:tium/presentation/home/screen/weather/juso_search_screen.dart';
import 'package:tium/presentation/information/screen/information_screen.dart';
import 'package:tium/presentation/main/main_screen.dart';
import 'package:tium/presentation/mypage/screen/license/oss_license_screen.dart';
import 'package:tium/presentation/mypage/screen/mypage_screen.dart';
import 'package:tium/presentation/mypage/screen/theme/theme_screen.dart';
import 'package:tium/presentation/onboarding/bloc/recommendation/recommend_plant_bloc.dart';
import 'package:tium/presentation/onboarding/bloc/recommendation/recommend_plant_event.dart';
import 'package:tium/presentation/onboarding/screen/onboarding_intro_screen.dart';
import 'package:tium/presentation/onboarding/screen/onboarding_result_screen.dart';
import 'package:tium/presentation/onboarding/screen/onboarding_screen.dart';
import 'package:tium/presentation/plant/screen/search_detail_screen.dart';
import 'package:tium/presentation/search/screen/search_screen.dart';
import 'package:tium/presentation/web/screen/web_view_screen.dart';

/// Screen Routes
class Routes {
  static const String splash = '/';
  static const String main = '/main'; // 메인
  static const String intro = '/intro'; // 앱 소개 (첫 실행 시)
  static const String onboarding = '/onboarding'; // 온보딩
  static const String userType = '/userType'; // 유저타입 확인

  // tab
  static const String home = '/home'; // 홈 (탭바)
  static const String information = '/information'; // 정보 (탭바)
  static const String search = '/search'; // 검색 (탭바)
  static const String mypage = '/mypage'; // 마임페이지 (탭바)

  // sub screen
  static const String juso = '/juso'; // 주소검색
  static const String sectionlist = '/sectionlist'; // 필터링 된 식물 리스트
  static const String plantDetail = '/plantDetail'; // 식물 상세보기


  // settings
  static const String notification = '/notification'; // 알림 설정
  static const String theme = '/theme'; // 테마설정
  static const String openSource = '/opensource'; // 오픈소스
  static const String webView = '/webView'; // 웹뷰
}

/// WebView Routes
class WebRoutes {
  static const String appSite= 'https://momentous-wallet-0f7.notion.site/21a1c3f0e00380b4b1f9cc830a35b448?source=copy_link'; // 앱 사이트
  static const String termsOfUse = 'https://momentous-wallet-0f7.notion.site/21a1c3f0e003802a81e6d9932d129c4d?source=copy_link'; // 이용약관
  static const String privacyPolicy = 'https://momentous-wallet-0f7.notion.site/21a1c3f0e00380749fdcf3d0163fb065?source=copy_link'; // 개인정보 보호
}

/// AppRouter
class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.main:
        return MaterialPageRoute(
          builder: (_) => MainScreen(),
        );

      case Routes.intro:
        return MaterialPageRoute(
          builder: (_) => const OnboardingIntroScreen(),
        );

      case Routes.onboarding:
        final isHomePushed = settings.arguments as bool;
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(isHomePushed: isHomePushed,),
        );

      case Routes.userType:
        final args = settings.arguments as Map<String, dynamic>;
        final userType = args['userType'] as UserType;
        final isFirstRun = args['isFirstRun'] as bool;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => locator<RecommendationBloc>()..add(
              LoadUserRecommendations(userType: userType),
            ),
            child: OnboardingResultScreen(
              userType: userType,
              isFirstRun: isFirstRun,
            ),
          ),
        );

      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case Routes.juso:
        return MaterialPageRoute(
          builder: (_) => const JusoSearchScreen(),
        );

      case Routes.search:
        return MaterialPageRoute(
          builder: (_) => const SearchScreen(),
        );

      case Routes.information:
        return MaterialPageRoute(
          builder: (_) => const InformationScreen(),
        );

      case Routes.sectionlist:
        final args = settings.arguments as Map<String, dynamic>;
        final title = args['title'] as String;
        final filter = args['filter'] as Map<String, String>;
        final limit = args['limit'] as int? ?? 20;

        return MaterialPageRoute(
          builder: (_) => PlantSectionListScreen(
            title: title,
            filter: filter,
            limit: limit,
          ),
        );

      case Routes.plantDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final plantId = args['id'] as String;
        final category = args['category'] as PlantCategory;
        final imageUrl = args['imageUrl'] as String;
        final name = args['name'] as String;
        return MaterialPageRoute(
          builder: (_) => PlantDetailScreen(
            plantId: plantId,
            category: category,
            imageUrl: imageUrl,
            name: name,
          ),
        );
      case Routes.mypage:
        return MaterialPageRoute(
          builder: (_) => const MyPageScreen(),
        );
      case Routes.theme:
        return MaterialPageRoute(
          builder: (_) => ThemeScreen(),
        );
      case Routes.openSource:
        return MaterialPageRoute(
          builder: (_) => OssLicensesPage(),
        );
      case Routes.webView:
        final url = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => WebViewScreen(url: url),
        );
      default:
        return null;
    }
  }
}
