import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tium/core/services/Image_storage_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> pickImageFromGallery(BuildContext context, void Function(String?) onImagePicked) async {
  if (Platform.isAndroid) {
    final granted = await _requestGalleryPermission();
    if (!granted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('갤러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.')),
      );
      return;
    }
  }

  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked == null) {
    onImagePicked(null); // 이미지를 선택하지 않은 경우 null 전달
    return;
  }

  final dir = await getApplicationDocumentsDirectory();
  final targetPath = path.join(dir.path, 'temp_${DateTime.now().millisecondsSinceEpoch}.jpg'); // 임시 경로

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
      onImagePicked(null); // 압축 실패 시 null 전달
    }
  }
}

Future<bool> _requestGalleryPermission() async {
  if (Platform.isAndroid) {
    final androidVersion = await _getAndroidVersion();
    if (androidVersion >= 33) {
      final result = await Permission.photos.request();
      return result.isGranted;
    } else {
      final result = await Permission.storage.request();
      return result.isGranted;
    }
  }

  return true; // iOS는 무조건 true 처리
}

Future<int> _getAndroidVersion() async {
  final androidVersion = await DeviceInfoPlugin().androidInfo;
  return androidVersion.version.sdkInt;
}
