import 'package:flutter/material.dart';
import 'package:tium/core/routes/routes.dart';

/// 위치 설정 dialog

void showLocationChoiceDialog(BuildContext context, {required VoidCallback onUseCurrent}) {
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
                onUseCurrent(); // 현재 위치정보 설정
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
