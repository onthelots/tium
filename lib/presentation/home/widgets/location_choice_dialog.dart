import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/presentation/home/bloc/location/location_search_bloc.dart';
import 'package:tium/presentation/home/bloc/location/location_search_event.dart';

/// 위치 설정 dialog

void showLocationChoiceDialog(BuildContext context) {
  final theme = Theme.of(context);
  final textStyle = theme.textTheme.titleMedium;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _getCurrentLocationAndUpdate(context);
              },
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: theme.dividerColor.withOpacity(0.5), thickness: 1, height: 1),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, Routes.juso); // 주소검색으로 이동
              },
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
