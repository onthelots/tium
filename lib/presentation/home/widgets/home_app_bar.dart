import 'package:flutter/material.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/home/bloc/weather/weather_state.dart';
import 'package:tium/presentation/home/utils/hero_content_resolver.dart';

/// home app bar

class HomeAppBar extends StatelessWidget {
  final WeatherState state;
  final UserModel? user;
  final VoidCallback onLocationTap;

  const HomeAppBar({
    super.key,
    required this.state,
    required this.user,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hero = resolveHeroContent(state, user);

    final collapsedHeadline = (state is WeatherLoaded)
        ? '${(state as WeatherLoaded).weather.temperature.toString()}°C / UV ${interpretUVLevel((state as WeatherLoaded).uvIndex.value)}'
        : '티움';

    return SliverAppBar(
      pinned: true,
      expandedHeight: 260, // 기존 350 → 줄임
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
                Text(
                  collapsedHeadline,
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                if (hero.showLocationBtn)
                  IconButton(
                    icon: const Icon(Icons.location_searching, color: Colors.white),
                    onPressed: onLocationTap,
                  ),
              ],
            )
                : null,
            background: Stack(
              fit: StackFit.expand,
              children: [
                // background image
                Image.asset(hero.backgroundImage, fit: BoxFit.cover),

                // opacity
                Container(color: Colors.black.withOpacity(0.3)),

                // weather contents
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Icon(hero.icon, color: hero.iconColor, size: 50),

                      const SizedBox(height: 16),

                      Text(
                        hero.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        hero.subtitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      if (hero.showLocationBtn)
                        ElevatedButton.icon(
                          onPressed: onLocationTap,
                          icon: Icon(user == null ? Icons.tips_and_updates : Icons.my_location, color: Colors.white),
                          label: Text(
                            user == null ? '내 정보 설정하기' : '위치 설정하기',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
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
}
