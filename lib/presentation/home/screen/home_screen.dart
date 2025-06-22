import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tium/core/constants.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  // flags
  bool _isCollapsed = false; // 상단 AppBar 접힘여부 확인
  bool _loading = true;

  // data
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll); // Scroll Listener
    _fetchAll(); // Home Screen 구성 정보 불러오기
  }

  // Scroll Listener (scroll offset을 기반으로 isCollapsed (접힘여부) 확인
  void _handleScroll() {
    if (_scrollController.hasClients && _scrollController.offset > 100) {
      if (!_isCollapsed) setState(() => _isCollapsed = true);
    } else {
      if (_isCollapsed) setState(() => _isCollapsed = false);
    }
  }

  Future<void> _fetchAll() async {
    _user = await UserPrefs.getUser(); // 유저정보

    // 유저정보 내 위치정보
    if (_user?.location != null) {
      final loc = _user!.location!;
      final grid = LatLngGridConverter.latLngToGrid(loc.lat, loc.lng);

      // 날씨정보 불러오기
      context.read<WeatherBloc>().add(LoadWeather(
        areaCode: loc.areaCode,
        nx: grid.x,
        ny: grid.y,
      ));
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            _loading = true;  // 다시 로딩 상태로 돌리기
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
        backgroundColor: AppColors.lightBackground,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) => _buildSliverAppBar(theme, state),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────── SliverAppBar
  SliverAppBar _buildSliverAppBar(ThemeData theme, WeatherState state) {
    String temp = '--';
    String uv = '--';

    if (state is WeatherLoaded) {
      temp = state.temperature.value.toString();
      uv = _interpretUVLevel(state.uvIndex.value);
    }

    final bool needLocation = _user?.location == null;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 150,
      centerTitle: true,
      backgroundColor: AppColors.lightPrimary,
      title: _isCollapsed
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$temp°C / 자외선지수 $uv',
              style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
          if (needLocation)
            IconButton(
              icon: const Icon(Icons.location_searching, color: Colors.white),
              onPressed: () {
              },
            ),
        ],
      )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
          alignment: Alignment.bottomLeft,
          color: theme.primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('안녕하세요, OOO님',
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$temp°C  ☀  자외선지수 $uv',
                      style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
                  if (needLocation)
                    IconButton(
                      icon: const Icon(Icons.location_searching, color: Colors.white),
                      onPressed: () => _handleLocationTap(context),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _interpretUVLevel(int uv) {
    if (uv < 3) return '낮음';
    if (uv < 6) return '보통';
    if (uv < 8) return '높음';
    if (uv < 11) return '매우 높음';
    return '위험';
  }

  // 유저 정보가 없을 경우
  Future<void> _handleLocationTap(BuildContext context) async {
    if (_user == null) {
      await Navigator.pushNamed(context, Routes.onboarding, arguments: true);
      await _fetchAll();
    } else {
      _showLocationChoiceDialog(context);
    }
  }

  void _showLocationChoiceDialog(BuildContext parentCtx) {
    showModalBottomSheet(
      context: parentCtx,
      builder: (sheetCtx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.gps_fixed),
                title: Text('현재 위치 사용하기'),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await _getCurrentLocationAndUpdate(parentCtx);
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text('주소로 검색하기'),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  Navigator.pushNamed(context, Routes.juso);
                },
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
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('위치 권한이 거부되었습니다.')),
          );
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
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('위치 정보를 가져오지 못했습니다: $e')),
      );
    }
  }
}