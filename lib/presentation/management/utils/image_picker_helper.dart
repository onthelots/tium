import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tium/core/services/Image_storage_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> pickImageFromGallery(BuildContext context, void Function(String?) onImagePicked) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked == null) {
    onImagePicked(null); // 이미지를 선택하지 않은 경우 null 전달
    return;
  }

  final dir = await getApplicationDocumentsDirectory();
  final targetPath = path.join(dir.path, 'temp_${DateTime.now().millisecondsSinceEpoch}.jpg');

  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    picked.path,
    targetPath,
    format: CompressFormat.jpeg,
    quality: 90,
  );

  if (compressedFile != null) {
    final savedRelativePath = await ImageStorageService.saveImageFile(File(compressedFile.path));
    if (context.mounted) {
      onImagePicked(savedRelativePath);
    }
  } else {
    if (context.mounted) {
      onImagePicked(null);
    }
  }
}
