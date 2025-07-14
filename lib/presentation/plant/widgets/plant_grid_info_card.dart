import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PlantGridInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const PlantGridInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.disabledColor, width: 0.2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            height: 120, // Card 내 최대 높이를 고정 (필요시 조절)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: theme.primaryColor, size: 28),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded( // 남은 공간을 텍스트가 차지하게 함
                  child: AutoSizeText(
                    value,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    minFontSize: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
