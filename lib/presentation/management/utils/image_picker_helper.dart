import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> pickImageFromGallery(BuildContext context, void Function(File) onImagePicked) async {
  final granted = await Permission.photos.request().isGranted || await Permission.storage.request().isGranted;

  if (!granted) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('갤러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.')),
    );
    return;
  }

  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked == null) return;

  final dir = await getApplicationDocumentsDirectory();
  final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

  // ✅ HEIC -> JPEG 변환 및 저장
  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    picked.path,
    targetPath,
    format: CompressFormat.jpeg,
    quality: 90,
  );

  // ✅ 변환 성공 시 File 전달
  if (compressedFile != null && context.mounted) {
    onImagePicked(File(compressedFile.path));
  }
}
