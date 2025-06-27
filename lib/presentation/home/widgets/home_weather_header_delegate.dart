import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/home/bloc/weather/weather_event.dart';
import 'package:tium/presentation/home/bloc/weather/weather_state.dart';
import 'package:tium/presentation/home/utils/hero_content_resolver.dart';

import '../bloc/weather/weather_bloc.dart' show WeatherBloc;

class WeatherStatusHeaderDelegate extends SliverPersistentHeaderDelegate {
  final UserModel? user;
  final VoidCallback onLocationTap;
  final VoidCallback onRetry; // ✅ 추가: 날씨 재요청 콜백

  WeatherStatusHeaderDelegate({
    required this.user,
    required this.onLocationTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final weatherState = context.watch<WeatherBloc>().state;
    final hero = resolveHeroContent(weatherState, user);
    final isDay = hero.isDay;

    final uv = (weatherState is WeatherLoaded) ? weatherState.uvIndex.value : null;
    final temperature = (weatherState is WeatherLoaded)
        ? "${weatherState.weather.temperature.toStringAsFixed(1)}°C"
        : null;

    final locationText = '${user?.location?.sido ?? ''} ${user?.location?.dong ?? ''}'.trim();

    return Container(
      height: maxExtent,
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: user?.location == null
          ? _buildEmptyLocationRow(theme)
          : Builder(
        builder: (context) {
          if (weatherState is WeatherError) {
            return Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '날씨 정보를 불러오지 못했어요.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(4)),
                  child: const Text('다시 시도'),
                ),
              ],
            );
          }

          // ✅ 정상 상태
          return Row(
            children: [
              Icon(Icons.location_on, color: theme.highlightColor, size: 24),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  locationText.isEmpty ? '내 동네' : locationText,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 10), // 텍스트와 아이콘 사이 여백 확보

              if (weatherState is WeatherLoaded)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(hero.icon, color: hero.iconColor, size: 24),
                    const SizedBox(width: 8),
                    Text(temperature ?? '', style: theme.textTheme.labelMedium),
                    const SizedBox(width: 8),
                    if (uv != null && isDay)
                      Text('(자외선 ${interpretUVLevel(uv)})',
                          style: theme.textTheme.bodySmall),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }


  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant WeatherStatusHeaderDelegate oldDelegate) => true;

  Widget _buildEmptyLocationRow(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.location_on, color: theme.highlightColor, size: 24),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            "우리 동네의 현재 날씨가 궁금하신가요?",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w300,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          onTap: onLocationTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.location_searching, size: 16),
                const SizedBox(width: 4),
                Text(
                  '위치확인',
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

