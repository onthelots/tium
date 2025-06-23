import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tium/core/constants/app_asset.dart';
import 'package:tium/core/constants/constants.dart';
import 'package:tium/core/helper/lat_lng_grid_converter.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/home/bloc/location/location_search_bloc.dart';
import 'package:tium/presentation/home/bloc/location/location_search_event.dart';
import 'package:tium/presentation/home/bloc/location/location_search_state.dart';
import 'package:tium/presentation/home/bloc/weather/weather_bloc.dart';
import 'package:tium/presentation/home/bloc/weather/weather_event.dart';
import 'package:tium/presentation/home/bloc/weather/weather_state.dart';

class HeroContent {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showLocationBtn;

  const HeroContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.showLocationBtn = false,
  });
}

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

  // 초기값 할당
  Future<void> _fetchAll() async {
    _user = await UserPrefs.getUser();
    if (_user?.location != null) {
      final loc = _user!.location!;
      final grid = LatLngGridConverter.latLngToGrid(loc.lat, loc.lng);
      context.read<WeatherBloc>().add(
        LoadWeather(areaCode: loc.areaCode, nx: grid.x, ny: grid.y),
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) => _buildSliverAppBar(theme, state),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildProjectsHeader(theme)),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildProjectsList()),
            // const SliverToBoxAdapter(child: SizedBox(height: 12)),
            // SliverToBoxAdapter(child: _buildProjectsList()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────── Hero content map
  HeroContent _resolveHeroContent(WeatherState state) {
    if (_user == null) {
      return HeroContent(
        icon: Icons.waving_hand,
        iconColor: AppColors.lightAccent,
        title: '티움에 오신 걸 환영해요!',
        subtitle: '사용자 정보를 설정하고\n지금 날씨를 알아볼까요?',
        showLocationBtn: true,
      );
    }

    if (_user!.location == null) {
      return HeroContent(
        icon: Icons.location_on,
        iconColor: Colors.redAccent,
        title: '내 위치를 알려주세요',
        subtitle: '식물이 있는 곳의 날씨를 알려드릴게요',
        showLocationBtn: true,
      );
    }

    if (state is! WeatherLoaded) {
      return HeroContent(
        icon: Icons.downloading,
        iconColor: Colors.blueGrey,
        title: '잠시만 기다려 주세요...',
        subtitle: '최신 날씨를 확인하고 있어요',
      );
    }

    final temp = state.weather.temperature.toStringAsFixed(1);
    final uvLevel = _interpretUVLevel(state.uvIndex.value);
    final condition = state.weather.condition;

    IconData icon = Icons.wb_cloudy;
    Color color = Colors.white;
    String title = '날씨를 확인해보세요!';
    String subtitle = '현재 $temp°C / UV $uvLevel';

    switch (condition) {
      case '맑음':
        icon = Icons.wb_sunny;
        color = Colors.amberAccent;
        title = '햇살이 가득해요!';
        break;
      case '구름 많음':
        icon = Icons.cloud;
        color = Colors.grey.shade400;
        title = '구름이 살포시 있어요';
        break;
      case '흐림':
        icon = Icons.cloud_queue;
        color = Colors.grey.shade600;
        title = '하늘이 조금 흐릿해요';
        break;
      case '비':
      case '소나기':
        icon = Icons.umbrella;
        color = Colors.blue.shade300;
        title = '비가 내려요 🌧';
        break;
      case '눈':
        icon = Icons.ac_unit;
        color = Colors.lightBlue.shade100;
        title = '눈송이가 내려요 ❄️';
        break;
      case '비/눈':
        icon = Icons.grain;
        color = Colors.indigo.shade200;
        title = '비와 눈이 함께 내려요';
        break;
      default:
        icon = Icons.thermostat;
        color = Colors.orangeAccent;
        title = '날씨 정보';
        break;
    }

    return HeroContent(
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: subtitle,
    );
  }


  // ───────────────────────────────────────────────────────── SliverAppBar
  SliverAppBar _buildSliverAppBar(ThemeData theme, WeatherState state) {
    final hero = _resolveHeroContent(state);
    final bool needLocation = hero.showLocationBtn;

    String collapsedHeadline;

    if (state is WeatherLoaded) {
      final temp = state.weather.temperature.toString();
      final uv = _interpretUVLevel(state.uvIndex.value);
      collapsedHeadline = '$temp°C  /  UV $uv';
    } else {
      collapsedHeadline = '티움';
    }

    return SliverAppBar(
      pinned: true,
      expandedHeight: 350,
      elevation: 0,
      backgroundColor: theme.colorScheme.primary,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final collapsed = constraints.maxHeight <=
              kToolbarHeight + MediaQuery.of(context).padding.top + 10;

          return FlexibleSpaceBar(
            titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 12),
            centerTitle: false,
            title: collapsed
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(collapsedHeadline,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                if (needLocation)
                  IconButton(
                    icon: const Icon(Icons.location_searching, color: Colors.white),
                    onPressed: () => _handleLocationTap(context),
                  ),
              ],
            )
                : null,
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(AppAsset.home.indoor_bg, fit: BoxFit.cover),
                Container(color: Colors.black.withOpacity(0.6)),
                // Hero content
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Icon
                      Icon(
                        hero.icon,
                        color: hero.iconColor,
                        size: 50,
                      ),
                      const SizedBox(height: 25),

                      // 타이틀
                      Text(hero.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 8),

                      // 서브타이틀
                      Text(hero.subtitle,
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),

                      const SizedBox(height: 25),

                      // 하단 Button & weather 정보
                      if (hero.showLocationBtn)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _handleLocationTap(context),
                          icon: _user == null ? Icon(Icons.tips_and_updates, color: Colors.white) : Icon(Icons.my_location, color: Colors.white),
                          label: Text(_user == null ? '내 정보 설정하기' : '위치 설정하기',
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // UV 설정
  String _interpretUVLevel(int uv) {
    if (uv < 3) return '낮음';
    if (uv < 6) return '보통';
    if (uv < 8) return '높음';
    if (uv < 11) return '매우 높음';
    return '위험';
  }

  Future<void> _handleLocationTap(BuildContext context) async {
    if (_user == null) {
      await Navigator.pushNamed(context, Routes.onboarding, arguments: true);
      await _fetchAll();
    } else {
      _showLocationChoiceDialog(context);
    }
  }

  // 위치정보 선택 Dialog
  void _showLocationChoiceDialog(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.titleMedium;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 현재 위치 선택 영역
              InkWell(
                onTap: () async {
                  Navigator.pop(ctx);
                  await _getCurrentLocationAndUpdate(context);
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                splashColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.my_location, size: 28, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Text('현재 위치로 설정', style: textStyle?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              // 부드러운 구분선
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: theme.dividerColor.withOpacity(0.5),
                  thickness: 1,
                  height: 1,
                ),
              ),

              // 주소 검색 선택 영역
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, Routes.juso);
                },
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                splashColor: theme.colorScheme.secondary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 28, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Text('주소로 검색하기', style: textStyle?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          if (!ctx.mounted) return;
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(const SnackBar(content: Text('위치 권한이 거부되었습니다.')));
          return;
        }
      }

      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (!ctx.mounted) return;
      ctx.read<LocationBloc>().add(
        LocationByLatLngRequested(position.latitude, position.longitude),
      );
    } catch (e) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text('위치 정보를 가져오지 못했습니다: $e')));
    }
  }

  // 1. section header
  Widget _buildProjectsHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Today Plants',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('See all')),
        ],
      ),
    );
  }

  // 2. Horizontal projects list
  Widget _buildProjectsList() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildProjectCard(
              'Panama Reforestation Project',
              'Gold Standard',
              AppAsset.home.indoor_bg,
            );
          }
          return _buildProjectCard(
            'Mauritan Project',
            'Verified Climate Standard',
            AppAsset.home.outdoor_bg,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 2,
      ),
    );
  }

  // 3. Project card widget
  Widget _buildProjectCard(String title, String subtitle, String imagePath) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
