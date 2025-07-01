import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageStorageService {
  static Future<File?> pickAndSaveImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (picked == null) return null;

      final tempImage = File(picked.path);

      // 1. 앱의 문서 디렉토리 가져오기
      final appDir = await getApplicationDocumentsDirectory();

      // 2. 고유 파일 이름 생성
      final extension = path.extension(picked.path); // .jpg, .png 등
      final uniqueFileName = 'plant_${DateTime.now().millisecondsSinceEpoch}$extension';

      // 3. 복사 경로 설정
      final savedImagePath = path.join(appDir.path, uniqueFileName);

      // 4. 이미지 복사하여 영구 저장
      final savedImage = await tempImage.copy(savedImagePath);

      return savedImage;
    } catch (e) {
      print('이미지 저장 중 오류 발생: $e');
      return null;
    }
  }

  /// 이미지 파일 삭제 (필요 시 호출)
  static Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
