import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/di/locator.dart';
import 'package:tium/data/models/plant/plant_category_model.dart';
import 'package:tium/data/models/plant/plant_summary_api_model.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/data/models/user/user_type_model.dart';
import 'package:tium/domain/usecases/onboarding/get_user_type_model_from_enum_usecase.dart';
import 'package:tium/presentation/home/screen/home_screen.dart';
import 'package:tium/presentation/home/screen/plant_section/plant_section_list_screen.dart';
import 'package:tium/presentation/home/screen/weather/juso_search_screen.dart';
import 'package:tium/presentation/main/screen/main_screen.dart';
import 'package:tium/presentation/management/screen/management_screen.dart';
import 'package:tium/presentation/management/screen/my_plant_detail_screen.dart';
import 'package:tium/presentation/management/screen/my_plant_edit_screen.dart';
import 'package:tium/presentation/mypage/screen/license/oss_license_screen.dart';
import 'package:tium/presentation/mypage/screen/mypage_screen.dart';
import 'package:tium/presentation/mypage/screen/notification/notification_time_setting_screen.dart';
import 'package:tium/presentation/mypage/screen/theme/theme_screen.dart';
import 'package:tium/presentation/onboarding/screen/onboarding_intro_screen.dart';
import 'package:tium/presentation/onboarding/screen/onboarding_result_screen.dart';
import 'package:tium/presentation/onboarding/screen/onboarding_screen.dart';
import 'package:tium/presentation/plant/screen/plant_detail_screen.dart';
import 'package:tium/presentation/search/screen/search_screen.dart';
import 'package:tium/presentation/splash/splash_screen.dart';
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
  static const String management = '/management'; // 내 식물 관리 (탭바)
  static const String search = '/search'; // 검색 (탭바)
  static const String mypage = '/mypage'; // 마임페이지 (탭바)

  // home
  static const String juso = '/juso'; // 주소검색
  static const String sectionlist = '/sectionlist'; // 필터링 된 식물 리스트
  static const String plantDetail = '/plantDetail'; // 식물 상세보기

  // management
  static const String myPlantDetail = '/myPlantDetail'; // 등록한 식물 상세보기
  static const String myPlantEdit = '/myPlantEdit'; // 등록한 식물 수정(혹은 삭제)

  // settings
  static const String notification = '/notification'; // 알림 설정
  static const String notificationTimeSetting = '/notificationTimeSetting'; // 알림 시간 설정
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
      case Routes.splash:
        final initialPayload = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => SplashScreen(initialPayload: initialPayload),
        );

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
        final userTypeModel = args['userType'] as UserTypeModel;
        final isFirstRun = args['isFirstRun'] as bool;
        return MaterialPageRoute(
          builder: (_) => OnboardingResultScreen(
            userType: userTypeModel,
            isFirstRun: isFirstRun,
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

      case Routes.management:
        return MaterialPageRoute(
          builder: (_) => const ManagementScreen(),
        );

      case Routes.myPlantDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final plant = args['plant'] as UserPlant;
        return MaterialPageRoute(
          settings: RouteSettings(name: Routes.myPlantDetail),
          builder: (_) => MyPlantDetailScreen(plant: plant),
        );

      case Routes.myPlantEdit:
        final args = settings.arguments as Map<String, dynamic>;
        final initialPlant = args['initialPlant'] as UserPlant;
        return MaterialPageRoute(
          builder: (_) => MyPlantEditScreen(initialPlant: initialPlant),
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
        final name = args['name'] as String;
        final id = args['id'] as String;
        final category = args['category'] as PlantCategory;
        final imageUrl = args['imageUrl'] as String;
        return MaterialPageRoute(
          builder: (_) => PlantDetailScreen(
            name: name,
            id: id,
            category: category,
            imageUrl: imageUrl,
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
      case Routes.notificationTimeSetting:
        return MaterialPageRoute(
          builder: (_) => const NotificationTimeSettingScreen(),
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