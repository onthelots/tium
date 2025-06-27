import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double size;
  final String? message;

  const CustomLoadingIndicator({
    super.key,
    this.size = 50,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.twistingDots(
            leftDotColor: theme.colorScheme.primary,
            rightDotColor: theme.colorScheme.secondary,
            size: size,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}