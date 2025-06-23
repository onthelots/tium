import 'package:flutter/material.dart';
import 'package:tium/core/constants/constants.dart';

class ColorComboPreviewSection extends StatelessWidget {
  const ColorComboPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('🎨 테마 색상 조합 테스트', style: Theme.of(context).textTheme.titleMedium),
        ),

        // 1. Primary 배경 위 텍스트/버튼
        Container(
          color: AppColors.lightPrimary,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Primary 배경', style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightAccent),
                onPressed: () {},
                child: const Text('Accent 버튼'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Secondary 배경 위 카드
        Container(
          color: AppColors.lightSecondary,
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 3,
            child: ListTile(
              leading: Icon(Icons.nature, color: AppColors.lightPrimary),
              title: Text('Card on Secondary'),
              subtitle: Text('Primary 컬러 아이콘, 배경 위 카드'),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. Background 위 텍스트/버튼 조합
        Container(
          color: AppColors.lightBackground,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Background 위 콘텐츠', style: TextStyle(color: AppColors.lightPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Filled'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outlined'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4. Tertiary, Accent 혼합 배경
        Row(
          children: [
            Expanded(
              child: Container(
                color: AppColors.lightTertiary,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('Tertiary'),
                    const SizedBox(height: 4),
                    Icon(Icons.spa, color: AppColors.lightPrimary),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.lightAccent,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('Accent'),
                    const SizedBox(height: 4),
                    Icon(Icons.wb_sunny, color: AppColors.lightPrimary),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
