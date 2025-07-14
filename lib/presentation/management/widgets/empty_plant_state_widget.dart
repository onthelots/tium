import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_platform_alert_dialog.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/data/models/plant/plant_summary_api_model.dart';
import 'package:tium/presentation/management/bloc/user_plant_bloc.dart';
import 'package:tium/presentation/management/bloc/user_plant_event.dart';
import 'package:tium/presentation/management/bloc/user_plant_state.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_bloc.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_state.dart';
import 'package:tium/presentation/search/screen/search_delegate.dart';

class EmptyPlantStateWidget extends StatelessWidget {
  const EmptyPlantStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded, size: 80, color: theme.primaryColor),
            const SizedBox(height: 20),
            Text(
              '등록된 식물이 없어요.\n나만의 식물을 등록하고 건강하게 관리해보세요!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.add, color: theme.primaryColor),
              label: Text(
                '식물 등록하기',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                backgroundColor: theme.colorScheme.tertiary,
                elevation: 4,
                shadowColor: Colors.black26,
              ),
              onPressed: () async {
                final user = await UserPrefs.getUser(); // Hive에서 유저정보 받아오기

                if (user == null) {
                  await showPlatformAlertDialog(
                    context: context,
                    title: '아직 준비가 필요해요 🌱',
                    content: '내 식물을 함께 키우려면, 먼저 몇 가지 정보를 간단히 알려주세요.\n기본 정보 입력 화면으로 이동할까요?',
                    confirmText: '온보딩 시작',
                    cancelText: '취소',
                    onConfirm: () {
                      Navigator.pushNamed(context, Routes.onboarding, arguments: true);
                    },
                    onCancel: () {},
                  );
                  return;
                }

                // 온보딩이 되어 있으면 식물 등록 화면으로 이동하는 콜백
                _onRegisterButtonPressed(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onRegisterButtonPressed(BuildContext context) {
    showSearch(
      context: context,
      delegate: PlantSearchDelegate(),
    ).then((_) {
      context.read<UserPlantBloc>().add(LoadUserPlant());
    });
  }
}
