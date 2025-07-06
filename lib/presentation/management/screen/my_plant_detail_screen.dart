import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tium/components/custom_platform_alert_dialog.dart';
import 'package:tium/components/custom_scaffold.dart';
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
  bool _isButtonDisabled = false;
  bool _hasNotificationPermission = true;

  late AnimationController _waterDropController;
  late Animation<double> _waterDropAnimation;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
    _checkWateringCooldown(); // 물주기 여부 확인 (today)
    _checkNotificationPermission(); // 알림 허용여부 확인

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

  // 물주기 여부 확인
  void _checkWateringCooldown() {
    final now = DateTime.now();
    final lastWateredDay = DateTime(
      _plant.lastWateredDate.year,
      _plant.lastWateredDate.month,
      _plant.lastWateredDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _isButtonDisabled = lastWateredDay.isAtSameMomentAs(today);
    });
  }

  // 알림권한 확인
  Future<void> _checkNotificationPermission() async {
    final granted = await LocalNotificationService().checkPermission();
    setState(() {
      _hasNotificationPermission = granted;
    });
  }

  String _nextWateringShortText() {
    final nextDate =
    _plant.lastWateredDate.add(Duration(days: _plant.wateringIntervalDays));
    final now = DateTime.now();
    final diff = nextDate.difference(DateTime(now.year, now.month, now.day)).inDays;

    if (diff < 0) return '⚠️';
    if (diff == 0) return 'D-Day';
    return 'D-$diff';
  }

  /// 다음 물주기 일정
  void _showWateringInfoDialog(BuildContext context) {
    final nextDate =
    _plant.lastWateredDate.add(Duration(days: _plant.wateringIntervalDays));
    final now = DateTime.now();
    final diff = nextDate.difference(DateTime(now.year, now.month, now.day)).inDays;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('다음 물주기 예정'),
        content: Text(
          '예정일: ${DateFormat('yyyy.MM.dd').format(nextDate)}\n'
              '남은 일수: ${diff < 0 ? '지났어요!' : 'D-$diff'}',
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

  Future<void> _handleWatering() async {
    final granted =
    await LocalNotificationService().requestPermissionIfNeeded(context);
    if (!granted) {
      setState(() => _hasNotificationPermission = false);
      Fluttertoast.showToast(
        msg: '알림 권한이 필요합니다. 설정에서 허용해주세요.',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      final updated = _plant.copyWith(lastWateredDate: DateTime.now());
      context.read<UserPlantBloc>().add(WaterPlant(updated, hasPermission: false));
      setState(() {
        _plant = updated;
        _checkWateringCooldown();
      });
      return;
    }

    if (_isButtonDisabled) {
      final confirmed = await showWateringConfirmationDialog(context);
      if (confirmed != true) return;
    }

    final updated = _plant.copyWith(lastWateredDate: DateTime.now());
    context.read<UserPlantBloc>().add(WaterPlant(updated, hasPermission: true));

    _waterDropController.forward();

    Fluttertoast.showToast(
      msg: "💧 물주기 완료!",
      gravity: ToastGravity.BOTTOM,
    );

    setState(() {
      _plant = updated;
      _checkWateringCooldown();
    });
  }

  /// 물주기 경고 (당일 이미 실행했을 때)
  Future<bool> showWateringConfirmationDialog(BuildContext context) async {
    bool confirmed = false;

    await showPlatformAlertDialog(
      context: context,
      title: '물주기 경고',
      content: '오늘 이미 물을 준 것으로 기록되어 있어요. 그래도 다시 물을 주시겠어요?',
      confirmText: '네',
      cancelText: '아니요',
      onConfirm: () => confirmed = true,
      onCancel: () => confirmed = false,
    );

    return confirmed;
  }

  void _toggleNotification(bool value) async {
    if (value) {
      final granted =
      await LocalNotificationService().requestPermissionIfNeeded(context);
      if (!granted) {
        setState(() => _hasNotificationPermission = false);
        Fluttertoast.showToast(
          msg: "⚠️ 알림 권한이 필요합니다!",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
        return;
      }

      // ✅ 여기에서 상태를 true로 갱신하세요!
      setState(() => _hasNotificationPermission = true);

      final now = DateTime.now();
      final diff = now.difference(_plant.lastWateredDate).inDays;

      if (diff > _plant.wateringIntervalDays) {
        Fluttertoast.showToast(
          msg: "마지막 물 준 날짜가 오래돼서 오늘로 갱신했어요!",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        _plant = _plant.copyWith(lastWateredDate: now);
        context.read<UserPlantBloc>().add(UpdatePlant(_plant));
      }

      context.read<UserPlantBloc>().add(ToggleReminder(_plant, true));
      Fluttertoast.showToast(
        msg: "물주기 알림을 활성화합니다",
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
      );
    } else {
      context.read<UserPlantBloc>().add(ToggleReminder(_plant, false));
      Fluttertoast.showToast(
        msg: "물주기 알림을 종료합니다",
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
      );
    }

    setState(() {
      _plant = _plant.copyWith(isWateringNotificationOn: value);
    });
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
            Navigator.pop(context); // ✅ 1st pop: DetailScreen
            return; // no need to update
          }

          if (result is UserPlant) {
            setState(() {
              _plant = result;
              _checkWateringCooldown();
            });
          }
        },
        child: Text('수정하기',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor, fontWeight: FontWeight.w300)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 식물 이름
            Text(
              _plant.name,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              _plant.scientificName,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 이미지 썸네일
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (() {
                  if (_plant.imagePath != null) {
                    final file = File(_plant.imagePath!);
                    if (file.existsSync()) {
                      return Image.file(
                        file,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Container(
                        height: 260,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.local_florist, size: 100, color: Colors.white),
                      );
                    }
                  } else {
                    return Container(
                      height: 260,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_florist, size: 100, color: Colors.white),
                    );
                  }
                })(),
              ),
            ),

            const SizedBox(height: 24),

            // 🔁 새롭게 구성한 버튼 Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // 🔔 알림 토글 버튼
                GestureDetector(
                  onTap: () => _toggleNotification(!_plant.isWateringNotificationOn),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.cardColor,
                        width: 5.0,
                      ),
                    ),
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
                            color: _plant.isWateringNotificationOn
                                ? Colors.white
                                : theme.cardColor,
                          ),
                          SizedBox(height: 3.0,),
                          Text(
                            _plant.isWateringNotificationOn ? "알림 ON" : "알림 OFF",
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // 물주기 버튼
                GestureDetector(
                  onTap: !_hasNotificationPermission ? null : _handleWatering,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.cardColor,
                        width: 5.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: _isButtonDisabled ? theme.disabledColor : Colors.lightBlueAccent,
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
                          children: [
                            const Icon(
                              Icons.water_drop,
                              color: Colors.white,
                              size: 40,
                            ),
                            SizedBox(height: 3.0,),
                            Text(
                              _isButtonDisabled ? "물주기 완료" : "물주기",
                              style: theme.textTheme.labelMedium?.copyWith(color: Colors.white,),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // D-Day 버튼
                GestureDetector(
                  onTap: () => _showWateringInfoDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(3), // border 두께
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.cardColor,
                        width: 5.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.hintColor,
                      child: Text(
                        _nextWateringShortText(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}