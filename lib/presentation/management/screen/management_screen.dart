import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/management/bloc/user_plant_bloc.dart';
import 'package:tium/presentation/management/bloc/user_plant_state.dart';

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
    if (userState is! UserPlantLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final allPlants = userState.user.indoorPlants;

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
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 4),
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
                    final file = File(plant.imagePath!);
                    if (file.existsSync()) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(file, fit: BoxFit.cover),
                      );
                    } else {
                      // 파일 없으면 기본 아이콘
                      return const Icon(Icons.local_florist, size: 32, color: Colors.white);
                    }
                  } else {
                    return const Icon(Icons.local_florist, size: 32, color: Colors.white);
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
                  child: Center(child: Icon(
                    Icons.notifications_off, color: theme.focusColor,),),
                ),
            ],
          ),
          title: Row(
            children: [
              Text(
                plant.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                plant.scientificName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w100,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  fontSize: 15.0
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
          }
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.dividerColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        title: Text('식물관리', style: theme.textTheme.labelLarge),
      ),
      body: Column(
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
      ),
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

List<UserPlant> createDummyPlants() {
  final now = DateTime.now();
  return [
    // 1. 오늘 물줘야 하는 식물 (nextWatering == 오늘)
    UserPlant(
      id: '1',
      name: '오늘 물줘야함',
      scientificName: 'Plantae One',
      difficulty: '쉬움',
      wateringCycle: '7~10일',
      isWateringNotificationOn: true,
      registeredDate: now.subtract(Duration(days: 20)),
      lastWateredDate: now.subtract(Duration(days: 7)), // 7일 후 = 오늘
      wateringIntervalDays: 7,
      notificationId: 101,
      imagePath: null,
      locations: ['거실'],
      cntntsNo: '1001',
    ),

    // 2. 물주기 이미 지난 식물 (nextWatering < 오늘)
    UserPlant(
      id: '2',
      name: '물줘야함',
      scientificName: 'Plantae Two',
      difficulty: '보통',
      wateringCycle: '5~7일',
      isWateringNotificationOn: true,
      registeredDate: now.subtract(Duration(days: 30)),
      lastWateredDate: now.subtract(Duration(days: 10)), // 10일 후 > 5일 간격 => 지난 상태
      wateringIntervalDays: 5,
      notificationId: 102,
      imagePath: null,
      locations: ['침실'],
      cntntsNo: '1002',
    ),

    // 3. 앞으로 물줘야 하는 식물 (nextWatering > 오늘)
    UserPlant(
      id: '3',
      name: '아직 물 안 줘도 됨',
      scientificName: 'Plantae Three',
      difficulty: '어려움',
      wateringCycle: '10~14일',
      isWateringNotificationOn: false,
      registeredDate: now.subtract(Duration(days: 5)),
      lastWateredDate: now.subtract(Duration(days: 3)), // 다음 물주는 날 7일 뒤 => 아직 안 됨
      wateringIntervalDays: 10,
      notificationId: null,
      imagePath: null,
      locations: ['주방'],
      cntntsNo: '1003',
    ),

    // 4. 알림 꺼진 식물 (isWateringNotificationOn == false)
    UserPlant(
      id: '4',
      name: '알림 꺼짐',
      scientificName: 'Plantae Four',
      difficulty: '보통',
      wateringCycle: '3~5일',
      isWateringNotificationOn: false,
      registeredDate: now.subtract(Duration(days: 12)),
      lastWateredDate: now.subtract(Duration(days: 3)),
      wateringIntervalDays: 3,
      notificationId: null,
      imagePath: null,
      locations: ['서재'],
      cntntsNo: '1004',
    ),

    // 5. 이미지가 있는 식물 (이미지 경로는 임의로 기입, 실제 이미지 파일은 없어도 됨)
    UserPlant(
      id: '5',
      name: '이미지 있음',
      scientificName: 'Plantae Five',
      difficulty: '쉬움',
      wateringCycle: '7~7일',
      isWateringNotificationOn: true,
      registeredDate: now.subtract(Duration(days: 15)),
      lastWateredDate: now.subtract(Duration(days: 7)),
      wateringIntervalDays: 7,
      notificationId: 105,
      imagePath: '/path/to/sample_image.jpg', // 실제 경로는 실행 환경에 맞게 변경
      locations: ['베란다'],
      cntntsNo: '1005',
    ),

    // 6. 여러 위치를 가진 식물
    UserPlant(
      id: '6',
      name: '다중 위치 식물',
      scientificName: 'Plantae Six',
      difficulty: '보통',
      wateringCycle: '6~9일',
      isWateringNotificationOn: true,
      registeredDate: now.subtract(Duration(days: 8)),
      lastWateredDate: now.subtract(Duration(days: 6)),
      wateringIntervalDays: 6,
      notificationId: 106,
      imagePath: null,
      locations: ['거실', '주방'],
      cntntsNo: '1006',
    ),
  ];
}
