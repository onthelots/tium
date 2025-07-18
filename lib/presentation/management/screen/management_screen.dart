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
import 'package:tium/presentation/search/screen/search_delegate.dart';

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
        title: Row(
          children: [
            Text('식물관리', style: theme.textTheme.labelLarge),
            const Spacer(),
            IconButton(
              onPressed: () async {
                showSearch(context: context, delegate: PlantSearchDelegate());
              },
              icon: const Icon(Icons.search),
            ),
          ]
        ),
      ),

      // 유저 상태에 따른 화면 분기
      body: switch (userState) {
        UserPlantLoading _ => const Center(child: CircularProgressIndicator()), // 로딩 중
        UserPlantError() => EmptyPlantStateWidget(), // 등록하기 (유저 온보딩 이동)
        UserPlantLoaded(:final user) => _buildLoadedBody(user), // 유저 정보 로딩 완료
        _ => const SizedBox.shrink(), // else
      },
    );
  }

  // 유저 정보 로딩 완료
  Widget _buildLoadedBody(UserModel user) {
    final theme = Theme.of(context);
    final allPlants = user.indoorPlants;

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
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(snapshot.data!, fit: BoxFit.cover),
                        );
                      } else if (snapshot.hasError) {
                        return buildImagePlaceholder(context);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  );
                } else {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const Icon(Icons.local_florist, size: 25, color: Colors.white)
                  );
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
          '${_formatNextWateringText(plant, todayOnly)}',
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
            height: MediaQuery.of(context).size.height - 200, // AppBar, padding 등 보정
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('등록된 식물이 없습니다'),
              ),
            ),
          ),
        );
      }

      return widgets;
    }

    return Column(
      children: [

        // 위치 선택
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

        // 식물 리스트
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
    if (diff < 0) return '물이 필요해요!';
    if (diff == 0) return 'D-DAY';
    return 'D-$diff';
  }
}
