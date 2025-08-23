import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/components/image_utils.dart';
import 'package:tium/core/notification/local_notification_service.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/management/bloc/user_plant_bloc.dart';
import 'package:tium/presentation/management/bloc/user_plant_event.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyPlantDetailScreen extends StatefulWidget {
  final UserPlant plant;
  const MyPlantDetailScreen({super.key, required this.plant});

  @override
  State<MyPlantDetailScreen> createState() => _MyPlantDetailScreenState();
}

class _MyPlantDetailScreenState extends State<MyPlantDetailScreen>
    with SingleTickerProviderStateMixin {
  late UserPlant _plant;
  late AnimationController _waterDropController;
  late Animation<double> _waterDropAnimation;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
    _checkNotificationPermission();

    // 기존 알림이 있으면 취소
    if (_plant.notificationId != null) {
      LocalNotificationService().cancelNotification(_plant.notificationId!);
      debugPrint("🔔 식물 상세 화면 진입: 알림 ID ${_plant.notificationId} 삭제");
    }

    _waterDropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _waterDropAnimation =
        CurvedAnimation(parent: _waterDropController, curve: Curves.easeOut);

    _waterDropController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _waterDropController.reset();
      }
    });
  }

  @override
  void dispose() {
    _waterDropController.dispose();
    super.dispose();
  }

  Future<void> _checkNotificationPermission() async {
    final granted = await LocalNotificationService().checkPermission();
  }

  /// 다음 물주기 일정
  void _showWateringInfoDialog(BuildContext context) {
    final nextDate = _plant.nextWateringDate ??
        _plant.lastWateredDate.add(Duration(days: _plant.wateringIntervalDays));
    final now = DateTime.now();
    final diff =
        nextDate.difference(DateTime(now.year, now.month, now.day)).inDays;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('다음 물주기 예정'),
        content: Text(
          '예정일: ${DateFormat('yyyy.MM.dd').format(nextDate)}\n'
              '${diff < 0 ? '이미 지났어요!' : 'D-$diff'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 물주기 버튼
  Future<void> _handleWatering() async {
    final granted =
    await LocalNotificationService().requestPermissionIfNeeded(context);

    if (!granted) {
      Fluttertoast.showToast(
        msg: '알림 권한이 필요합니다. 설정에서 허용해주세요.',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }

    final updated = _plant.copyWith(lastWateredDate: DateTime.now());
    context
        .read<UserPlantBloc>()
        .add(WaterPlant(updated, hasPermission: granted));

    _waterDropController.forward();

    Fluttertoast.showToast(
      msg: "💧 물주기 완료!",
      gravity: ToastGravity.BOTTOM,
    );

    setState(() {
      _plant = updated;
    });
  }

  /// 알림 설정 토글
  void _toggleNotification(bool value) async {
    if (value) {
      final granted =
      await LocalNotificationService().requestPermissionIfNeeded(context);
      if (!granted) {
        Fluttertoast.showToast(
          msg: "⚠️ 알림 권한이 필요합니다!",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
        return;
      }
    }

    context.read<UserPlantBloc>().add(ToggleReminder(_plant, value));
    setState(() => _plant = _plant.copyWith(isWateringNotificationOn: value));

    Fluttertoast.showToast(
      msg: value ? "물주기 알림을 활성화합니다" : "물주기 알림을 종료합니다",
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScaffold(
        appBarVisible: true,
      title: "내 식물 상세보기",
      trailing: TextButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
              context, Routes.myPlantEdit, arguments: {
            'initialPlant': widget.plant,
          });

          if (result == null) return;

          if (result is Map && result['deleted'] == true) {
            Navigator.pop(context);
            return; // no need to update
          }

          if (result is UserPlant) {
            setState(() {
              _plant = result;
            });
          }
        },
        child: Text('수정',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor, fontWeight: FontWeight.w300)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _plant.name,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              _plant.scientificName,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 이미지
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _plant.imagePath != null
                    ? FutureBuilder<File>(
                  future: getImageFileFromRelativePath(_plant.imagePath!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Image.file(
                        snapshot.data!,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        height: 260,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.local_florist,
                            size: 100, color: Colors.white),
                      );
                    } else {
                      return Container(
                        height: 260,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(
                            child: CircularProgressIndicator()),
                      );
                    }
                  },
                )
                    : Container(
                  height: 260,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.local_florist,
                      size: 100, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔔 알림
                GestureDetector(
                  onTap: () =>
                      _toggleNotification(!_plant.isWateringNotificationOn),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: _plant.isWateringNotificationOn
                        ? theme.primaryColor
                        : theme.disabledColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _plant.isWateringNotificationOn
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _plant.isWateringNotificationOn ? "알림 ON" : "알림 OFF",
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // 💧 물주기
                GestureDetector(
                  onTap: _handleWatering,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.lightBlueAccent,
                    child: AnimatedBuilder(
                      animation: _waterDropAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -20 * _waterDropAnimation.value),
                          child: Opacity(
                            opacity: 1 - _waterDropAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.water_drop, color: Colors.white, size: 40),
                          SizedBox(height: 3),
                          Text(
                            "물주기",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // D-Day
                GestureDetector(
                  onTap: () => _showWateringInfoDialog(context),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.hintColor,
                    child: _nextWateringWidget(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _nextWateringWidget() {
    final nextDate = _plant.nextWateringDate ??
        _plant.lastWateredDate.add(Duration(days: _plant.wateringIntervalDays));
    final now = DateTime.now();
    final diff =
        nextDate.difference(DateTime(now.year, now.month, now.day)).inDays;

    if (diff < 0) {
      return const Icon(Icons.warning, color: Colors.white, size: 20);
    } else if (diff == 0) {
      return const Text('D-DAY',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white));
    } else {
      return Text('D-$diff',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white));
    }
  }
}
