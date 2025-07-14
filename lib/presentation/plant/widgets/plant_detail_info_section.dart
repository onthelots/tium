import 'package:flutter/material.dart';

class PlantDetailInfoSection extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const PlantDetailInfoSection({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (value.isEmpty || value == '정보 없음') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: theme.hintColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(left: 28.0), // 아이콘 정렬 기준 맞춤
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
