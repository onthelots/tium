import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_platform_alert_dialog.dart';
import 'package:tium/core/constants/app_asset.dart';
import 'package:tium/core/helper/lat_lng_grid_converter.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/home/bloc/location/location_search_bloc.dart';
import 'package:tium/presentation/home/bloc/location/location_search_state.dart';
import 'package:tium/presentation/home/bloc/plant_section/plant_section_bloc.dart';
import 'package:tium/presentation/home/bloc/plant_section/plant_section_event.dart';
import 'package:tium/presentation/home/bloc/plant_section/plant_section_state.dart';
import 'package:tium/presentation/home/bloc/user_type/user_type_cubit.dart'; // UserTypeCubit 임포트
import 'package:tium/presentation/home/bloc/weather/weather_bloc.dart';
import 'package:tium/presentation/home/bloc/weather/weather_event.dart';
import 'package:tium/presentation/home/widgets/home_search_header_delegate.dart';
import 'package:tium/presentation/home/widgets/home_section_shimmer.dart';
import 'package:tium/presentation/home/widgets/home_weather_header_delegate.dart';
import 'package:tium/presentation/home/widgets/location_choice_dialog.dart';
import 'package:tium/presentation/landing/landing_screen.dart';
import 'plant_section/plant_section_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  /// 유저정보 불러오기
  Future<void> _fetchAll() async {
    _user = await UserPrefs.getUser();

    if (_user?.location != null) {
      final loc = _user!.location!;
      final grid = LatLngGridConverter.latLngToGrid(loc.lat, loc.lng);
      context.read<WeatherBloc>().add(
        LoadWeather(areaCode: loc.areaCode, nx: grid.x, ny: grid.y),
      );
    }

    // userType 기반 로드
    if (_user?.userType != null) {
      
      // 추천식물 섹션 로드
      context.read<RecommendationSectionBloc>().add(
        LoadUserRecommendationsSections(userType: _user!.userType),
      );
      
      // 유저 타입 로드
      context.read<UserTypeCubit>().loadUserTypeModel(
          _user!.userType);
    }

    setState(() => _loading = false);
  }

  /// 날씨 정보 불러오기(분리)
  void _handleWeatherReload() {
    final loc = _user?.location;
    if (loc != null) {
      final grid = LatLngGridConverter.latLngToGrid(loc.lat, loc.lng);
      print("🌦️ 날씨 다시 불러오기: ${loc.areaCode}, x=${grid.x}, y=${grid.y}");

      context.read<WeatherBloc>().add(
        LoadWeather(areaCode: loc.areaCode, nx: grid.x, ny: grid.y),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) async {
        if (state is LocationLoadSuccess) {
          final userLocation = state.location;
          setState(() {
            _user = _user?.copyWith(location: userLocation);
            _loading = true;
          });
          // 유저 정보 저장 (+ 위치정보)
          await UserPrefs.saveUser(_user!);
          await _fetchAll();
        } else if (state is LocationLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /// 앱바
              SliverAppBar(
                pinned: false, // 스크롤 시 사라지도록
                floating: false,
                snap: false,
                expandedHeight: 60,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.only(left: 16.0), // 정확하게 16만큼 떨어뜨리기
                  child: Row(
                    children: [
                      Image.asset(AppAsset.icon.icon_circle, height: 28),
                      const SizedBox(width: 10),
                      Text("TIUM", style: theme.textTheme.headlineSmall),
                      const Spacer(),
                      if (_user != null)
                        BlocBuilder<UserTypeCubit, UserTypeState>(
                          builder: (context, state) {
                            return IconButton(
                              onPressed: () async {
                                if (state is UserTypeLoaded) {
                                  Navigator.pushNamed(context, Routes.userType,
                                    arguments: {
                                      'userType': state.userTypeModel,
                                      'isFirstRun': false,
                                    },
                                  );
                                } else if (state is UserTypeError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.message)),
                                  );
                                }
                              },
                              icon: const Icon(Icons.account_circle),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                titleSpacing: 0, // 이건 0으로 맞춰두는 것이 좋음
              ),

              /// 날씨
              if (_user != null)
              SliverPersistentHeader(
                pinned: true,
                delegate: WeatherStatusHeaderDelegate(
                  user: _user,
                  onLocationTap: () => _handleLocationTap(context),
                  onRetry: _handleWeatherReload,
                ),
              ),

              /// 검색창
              SliverPersistentHeader(
                pinned: false,
                delegate: SearchBarHeaderDelegate(),
              ),

              /// 나머지 위젯
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 추천 식물 섹션 UI
                    _user == null

                    // 1. 랜딩 페이지
                        ? WelcomeLandingCard(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, Routes.onboarding, arguments: true);
                      },
                    )

                    // 2. 식물 추천 섹션
                        : BlocBuilder<RecommendationSectionBloc, RecommendationSectionState>(
                      builder: (context, state) {
                        if (state is RecommendationSectionLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: PlantSectionShimmer(),
                          );
                        } else if (state is RecommendationSectionLoaded) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: PlantSectionScreen(
                              sections: state.sections, // ← List<PlantSection>
                              onSeeMore: (title, filter) {
                                Navigator.pushNamed(
                                  context,
                                  Routes.sectionlist,
                                  arguments: {
                                    'title': title,
                                    'filter': filter,
                                    'limit': 100,
                                  },
                                );
                              },
                            ),
                          );
                        } else if (state is RecommendationSectionError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('추천 식물 로딩 중 오류: ${state.message}'),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 위치정보 받아오기
  Future<void> _handleLocationTap(BuildContext context) async {
    if (_user == null) {
      await showPlatformAlertDialog(
        context: context,
        title: '잠시만요 🌱',
        content: '식물을 돌보려면 먼저\n당신에 대해 조금만 알려주세요.\n\n귀찮게 하려는 건 아니에요 🙂\n더 잘 도와드리고 싶어서예요.',
        confirmText: '알겠어요',
        cancelText: '다음에 할게요',
        onConfirm: () async {
          await Navigator.pushNamed(context, Routes.onboarding, arguments: true);
          await _fetchAll();
        },
      );
    } else {
      showLocationChoiceDialog(
        context,
      );
    }
  }
}