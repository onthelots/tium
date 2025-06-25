import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_platform_alert_dialog.dart';
import 'package:tium/core/constants/app_asset.dart';
import 'package:tium/core/constants/constants.dart';
import 'package:tium/core/helper/lat_lng_grid_converter.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/home/bloc/location/location_search_bloc.dart';
import 'package:tium/presentation/home/bloc/location/location_search_event.dart';
import 'package:tium/presentation/home/bloc/location/location_search_state.dart';
import 'package:tium/presentation/home/bloc/plant_section/plant_section_bloc.dart';
import 'package:tium/presentation/home/bloc/plant_section/plant_section_event.dart';
import 'package:tium/presentation/home/bloc/plant_section/plant_section_state.dart';
import 'package:tium/presentation/home/bloc/weather/weather_bloc.dart';
import 'package:tium/presentation/home/bloc/weather/weather_event.dart';
import 'package:tium/presentation/home/bloc/weather/weather_state.dart';
import 'package:tium/presentation/home/utils/hero_content_resolver.dart';
import 'package:tium/presentation/home/widgets/location_choice_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_bloc.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_state.dart';
import 'package:tium/presentation/search/screen/search_delegate.dart';
import 'package:tium/presentation/search/screen/search_screen.dart';

import 'plant_section_screen.dart';

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

    // userType 기반 추천 식물 섹션 로드 이벤트 추가
    if (_user?.userType != null) {
      context.read<RecommendationSectionBloc>().add(
        LoadUserRecommendationsSections(userType: _user!.userType),
      );
    }

    setState(() => _loading = false);
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
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          toolbarHeight: 60,
          titleSpacing: 16,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Image.asset(AppAsset.icon.icon_circle, height: 28),
              const SizedBox(width: 10),
              Text("TIUM", style: theme.textTheme.titleMedium),
              const Spacer(),
              const Icon(Icons.notifications),
            ],
          ),
        ),

        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: PlantSearchDelegate([]), // 빈 리스트 → delegate 내부에서 상태 접근
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 20),
                            const SizedBox(width: 12),
                            Text("함께 하고 싶은 식물 검색", style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 날씨정보
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: _user?.location == null
                        ? Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24, // 원의 반지름 (size: 48)
                            backgroundColor: theme.colorScheme.secondary.withOpacity(0.2), // 배경색
                            child: Icon(
                              Icons.location_on,
                              color: theme.colorScheme.secondary,
                              size: 28, // 아이콘 크기
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                 "지금 날씨를 알려드릴게요",
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                 "먼저 위치 정보를 설정해 주세요", // 예: "26.5°C / 자외선 보통"
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: () => _handleLocationTap(context),
                          ),
                        ],
                      ),
                    )
                        : BlocBuilder<WeatherBloc, WeatherState>(
                      builder: (context, state) {
                        final hero = resolveHeroContent(state, _user);
                        final isDay = hero.isDay;
                        final uv = (state is WeatherLoaded) ? state.uvIndex.value : null;

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hero.icon,
                                color: hero.iconColor,
                                size: 30, // 첫 번째 예시 아이콘 크기와 동일하게 조정
                              ),
                              const SizedBox(width: 12), // 간격도 동일하게 12로 조정
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hero.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hero.subtitle,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (uv != null && isDay)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'UV ${interpretUVLevel(uv)}',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 추천 식물 섹션 UI
                  _user == null
                      ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '유저 정보가 없습니다. 온보딩을 진행해주세요.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                      : BlocBuilder<RecommendationSectionBloc, RecommendationSectionState>(
                    builder: (context, state) {
                      if (state is RecommendationSectionLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is RecommendationSectionLoaded) {
                        if (state.sections.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '추천 식물이 없습니다.',
                              style: theme.textTheme.bodyLarge,
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: state.sections.map((section) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        section.title,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => RecommendationFilteredPlantListScreen(
                                                title: section.title,
                                                filter: section.filter ?? {},
                                                limit: 20, // 더보기 화면에선 더 많이 요청
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text("더보기"),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 180, // 카드 높이 예시
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: section.plants.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                                      itemBuilder: (context, index) {
                                        final plant = section.plants[index];
                                        return PlantCard(plant: plant);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      } else if (state is RecommendationSectionError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('추천 식물 로딩 중 오류: ${state.message}', style: theme.textTheme.bodyLarge),
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
        onUseCurrent: () => _getCurrentLocationAndUpdate(context),
      );
    }
  }


  /// GPS 기반 위치정보 (location 전체 로직)
  Future<void> _getCurrentLocationAndUpdate(BuildContext ctx) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!ctx.mounted) return;
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('휴대폰 위치 서비스(GPS)가 꺼져 있습니다.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          if (!ctx.mounted) return;
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('위치 권한이 거부되었습니다.')),
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!ctx.mounted) return;
      ctx.read<LocationBloc>().add(
        LocationByLatLngRequested(position.latitude, position.longitude),
      );
    } catch (e) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('위치 정보를 가져오지 못했습니다: $e')),
      );
    }
  }
}

class PlantCard extends StatelessWidget {
  final PlantSummary plant;
  const PlantCard({required this.plant, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 140,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            plant.imageUrl != null
                ? Image.network(plant.imageUrl!, height: 100, width: double.infinity, fit: BoxFit.cover)
                : Container(height: 100, color: theme.colorScheme.primary.withOpacity(0.1)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                plant.name ?? '이름 없음',
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

