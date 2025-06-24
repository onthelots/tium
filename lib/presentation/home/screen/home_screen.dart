import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/helper/lat_lng_grid_converter.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/home/bloc/location/location_search_bloc.dart';
import 'package:tium/presentation/home/bloc/location/location_search_event.dart';
import 'package:tium/presentation/home/bloc/location/location_search_state.dart';
import 'package:tium/presentation/home/bloc/weather/weather_bloc.dart';
import 'package:tium/presentation/home/bloc/weather/weather_event.dart';
import 'package:tium/presentation/home/bloc/weather/weather_state.dart';
import 'package:tium/presentation/home/widgets/home_app_bar.dart';
import 'package:tium/presentation/home/widgets/home_event_list.dart';
import 'package:tium/presentation/home/widgets/location_choice_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tium/presentation/home/widgets/home_event_header.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) => HomeAppBar(
                state: state,
                user: _user,
                onLocationTap: () => _handleLocationTap(context),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // SliverToBoxAdapter(child: HomeEventHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: HomeEventList()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLocationTap(BuildContext context) async {
    if (_user == null) {
      await Navigator.pushNamed(context, Routes.onboarding, arguments: true);
      await _fetchAll();
    } else {
      showLocationChoiceDialog(context, onUseCurrent: () => _getCurrentLocationAndUpdate(context));
    }
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