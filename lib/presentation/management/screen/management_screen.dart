import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/image_utils.dart'; // Import the new utility file
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/management/bloc/user_plant_bloc.dart';
import 'package:tium/presentation/management/bloc/user_plant_event.dart';
import 'package:tium/presentation/management/bloc/user_plant_state.dart';
import 'package:tium/presentation/management/widgets/empty_plant_state_widget.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  static const locations = [
    '전체', '거실', '주방', '침실', '베란다', '욕실', '서재', '현관', '기타',
  ];

  String selectedLocation = '전체';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userState = context.watch<UserPlantBloc>().state;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.dividerColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        title: Text('식물관리', style: theme.textTheme.labelLarge),
      ),
      body: switch (userState) {
        UserPlantLoading _ => const Center(child: CircularProgressIndicator()),

        UserPlantError() => EmptyPlantStateWidget(),

        UserPlantLoaded(:final user) => _buildLoadedBody(user),

        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildLoadedBody(UserModel user) {
    final theme = Theme.of(context);
    final allPlants = user.indoorPlants;

    print("allPlants : ${allPlants.length}");

    if (allPlants.isEmpty) {
      return const EmptyPlantStateWidget();
    }

    final locationCounts = <String, int>{};
    for (var loc in locations.where((e) => e != '전체')) {
      locationCounts[loc] = allPlants.where((p) => p.locations.contains(loc)).length;
    }
    locationCounts['전체'] = allPlants.length;

    List<UserPlant> filteredPlants = selectedLocation == '전체'
        ? allPlants
        : allPlants.where((p) => p.locations.contains(selectedLocation)).toList();

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final needWaterToday = filteredPlants.where((p) {
      final nextWatering = p.lastWateredDate.add(Duration(days: p.wateringIntervalDays));
      final nextWateringDay = DateTime(nextWatering.year, nextWatering.month, nextWatering.day);
      return nextWateringDay.isAtSameMomentAs(todayOnly);
    }).toList();

    final overduePlants = filteredPlants.where((p) {
      final nextWatering = p.lastWateredDate.add(Duration(days: p.wateringIntervalDays));
      final nextWateringDay = DateTime(nextWatering.year, nextWatering.month, nextWatering.day);
      return nextWateringDay.isBefore(todayOnly);
    }).toList();

    final upcomingPlants = filteredPlants.where((p) {
      final nextWatering = p.lastWateredDate.add(Duration(days: p.wateringIntervalDays));
      final nextWateringDay = DateTime(nextWatering.year, nextWatering.month, nextWatering.day);
      return nextWateringDay.isAfter(todayOnly);
    }).toList();

    Widget buildPlantItem(UserPlant plant, {bool isOverdue = false, bool isToday = false}) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: (() {
                if (plant.imagePath != null) {
                  return FutureBuilder<File>(
                    future: getImageFileFromRelativePath(plant.imagePath!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        debugPrint('✅ ManagementScreen: Image file exists at ${snapshot.data!.path}');
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(snapshot.data!, fit: BoxFit.cover),
                        );
                      } else if (snapshot.hasError) {
                        debugPrint('❌ ManagementScreen: Error loading image: ${snapshot.error}');
                        return buildImagePlaceholder(context);
                      } else {
                        debugPrint('ℹ️ ManagementScreen: Loading image...');
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  );
                } else {
                  debugPrint('ℹ️ ManagementScreen: imagePath is null');
                  return buildImagePlaceholder(context);
                }
              })(),
            ),
            if (isOverdue)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            if (!plant.isWateringNotificationOn)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Icon(Icons.notifications_off, color: theme.focusColor)),
              ),
          ],
        ),
        title: Row(
          children: [
            Text(
              plant.name,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                plant.scientificName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w100,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  fontSize: 15.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '다음 물주기: ${_formatNextWateringText(plant, todayOnly)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: isOverdue
            ? const Icon(Icons.warning_amber_rounded, color: Colors.red)
            : isToday
            ? const Icon(Icons.water_drop_rounded, color: Colors.blue)
            : null,
        onTap: () {
          Navigator.pushNamed(context, Routes.myPlantDetail, arguments: {
            'plant': plant,
          });
        },
      );
    }

    List<Widget> buildPlantList() {
      final List<Widget> widgets = [];

      if (needWaterToday.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text('잊지말고 물주기', style: theme.textTheme.titleMedium),
        ));
        widgets.addAll(needWaterToday.map((p) => buildPlantItem(p, isToday: true)));
      }

      if (overduePlants.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text('물주기 이미 지난 식물', style: theme.textTheme.titleMedium),
        ));
        widgets.addAll(overduePlants.map((p) => buildPlantItem(p, isOverdue: true)));
      }

      if (upcomingPlants.isNotEmpty) {
        if (needWaterToday.isNotEmpty || overduePlants.isNotEmpty) {
          widgets.add(Divider(thickness: 10.0, height: 20.0, color: theme.dividerColor));
        }
        widgets.addAll(upcomingPlants.map((p) => buildPlantItem(p)));
      }

      if (widgets.isEmpty) {
        widgets.add(
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('등록된 식물이 없습니다.', style: theme.textTheme.bodyMedium),
              ),
            ),
          ),
        );
      }

      return widgets;
    }

    return Column(
      children: [
        Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: locations.map((loc) {
                final count = locationCounts[loc] ?? 0;
                final isSelected = loc == selectedLocation;
                return Padding(
                  padding: const EdgeInsets.only(right: 12, top: 16.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: isSelected ? theme.primaryColor : theme.cardColor,
                      foregroundColor: isSelected ? Colors.white : theme.disabledColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => setState(() => selectedLocation = loc),
                    child: Text(
                      '$loc ($count)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: buildPlantList(),
          ),
        ),
      ],
    );
  }

  String _formatNextWateringText(UserPlant plant, DateTime today) {
    final nextWateringDate = plant.lastWateredDate.add(Duration(days: plant.wateringIntervalDays));
    final diff = nextWateringDate.difference(today).inDays;
    if (diff < 0) return '물주기가 필요해요!';
    if (diff == 0) return '오늘 물주세요!';
    return 'D-$diff';
  }
}
