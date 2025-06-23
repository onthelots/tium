import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;
  final String? message;

  const CustomLoadingIndicator({
    super.key,
    this.color,
    this.size = 50,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? theme.primaryColor;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.waveDots(
            color: loadingColor,
            size: size,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(color: loadingColor),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}