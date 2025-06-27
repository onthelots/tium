import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool?> showAdaptiveAlert(
    BuildContext context, {
      required String title,
      required String content,
      String defaultActionText = '확인',
      String? cancelActionText,
    }) {
  final theme = Theme.of(context);
  final primaryColor = theme.primaryColor;

  if (Platform.isIOS) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,),
            const SizedBox(height: 12),
          ],
        ),
        content: Text(
          content,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actions: [
          if (cancelActionText != null)
            CupertinoDialogAction(
              child: Text(cancelActionText, style: theme.textTheme.bodyMedium),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              defaultActionText,
              style: theme.textTheme.bodyMedium?.copyWith(color: primaryColor),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  } else {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            content,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          if (cancelActionText != null)
            TextButton(
              child: Text(cancelActionText, style: theme.textTheme.bodyMedium),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          TextButton(
            child: Text(
              defaultActionText,
              style: theme.textTheme.bodyMedium?.copyWith(color: primaryColor),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
