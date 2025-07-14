import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/core/services/preference/notification_time_prefs.dart';
import 'package:tium/presentation/management/bloc/user_plant_bloc.dart';
import 'package:tium/presentation/management/bloc/user_plant_event.dart';

class NotificationTimeSettingScreen extends StatefulWidget {
  const NotificationTimeSettingScreen({super.key});

  @override
  State<NotificationTimeSettingScreen> createState() => _NotificationTimeSettingScreenState();
}

class _NotificationTimeSettingScreenState extends State<NotificationTimeSettingScreen> {
  TimeOfDay _notificationTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadNotificationTime();
  }

  Future<void> _loadNotificationTime() async {
    final time = await NotificationTimePrefs.getNotificationTime();
    setState(() {
      _notificationTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScaffold(
      appBarVisible: true,
      title: '알림 시간 설정',
      body: ListView.separated(
        itemCount: 2, // 알림 시간 ListTile과 주의사항 텍스트
        separatorBuilder: (context, index) => Divider(height: 5, thickness: 0.0, color: theme.scaffoldBackgroundColor),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              title: Text(
                '알림 시간',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _notificationTime.format(context),
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 8.0),
                  Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color, size: 18.0),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  showPicker(
                    context: context,
                    value: Time(
                      hour: _notificationTime.hour,
                      minute: _notificationTime.minute,
                    ),
                    onChange: (Time newTime) {
                      // onChange는 피커 내부에서 값이 변경될 때마다 호출되므로,
                      // 최종 선택된 값은 then 블록에서 처리합니다.
                    },
                    is24HrFormat: true,
                    accentColor: theme.primaryColor,
                    unselectedColor: theme.hintColor,
                    cancelText: '취소',
                    okText: '확인',
                    iosStylePicker: true,
                    displayHeader: false,
                  ),
                ).then((pickedTime) async {
                  final Time? finalPickedTime = pickedTime as Time?;
                  if (finalPickedTime != null) {
                    final newTimeOfDay = TimeOfDay(hour: finalPickedTime.hour, minute: finalPickedTime.minute);
                    if (newTimeOfDay != _notificationTime) {
                      setState(() {
                        _notificationTime = newTimeOfDay;
                      });
                      await NotificationTimePrefs.saveNotificationTime(newTimeOfDay);
                      if (mounted) {
                        context.read<UserPlantBloc>().add(UpdateAllNotificationTimes(newTimeOfDay));
                      }
                    }
                  }
                });
              },
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  height: 20.0,
                  indent: 16.0,
                  endIndent: 16.0,
                  color: theme.dividerColor,
                  thickness: 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    '알림 시간을 변경하면 예약된 모든 물주기 알림이\n새로운 시간으로 업데이트됩니다.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    '(단, 이미 알림 시간이 이미 지났을 경우 변경되지 않습니다)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
