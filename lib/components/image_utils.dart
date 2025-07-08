import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<File> getImageFileFromRelativePath(String relativePath) async {
  final appDir = await getApplicationDocumentsDirectory();
  final fullPath = path.join(appDir.path, relativePath);
  return File(fullPath);
}

Widget buildImagePlaceholder(BuildContext context) {
  final theme = Theme.of(context);
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.camera_alt_outlined, size: 36, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text('사진 선택', style: theme.textTheme.bodyMedium),
      ],
    ),
  );
}
