import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageStorageService {
  /// 이미지 파일을 앱 문서 디렉토리에 저장하고 상대 경로를 반환
  static Future<String?> saveImageFile(File tempImage) async {
    try {
      // 1. 앱의 문서 디렉토리 가져오기
      final appDir = await getApplicationDocumentsDirectory();

      // 2. 고유 파일 이름 생성
      final extension = path.extension(tempImage.path); // .jpg, .png 등
      final uniqueFileName = 'plant_${DateTime.now().millisecondsSinceEpoch}$extension';

      // 3. 복사 경로 설정
      final savedImagePath = path.join(appDir.path, uniqueFileName);

      // 4. 이미지 복사하여 영구 저장
      await tempImage.copy(savedImagePath);

      return uniqueFileName; // 고유 파일 이름만 반환
    } catch (e) {
      print('이미지 저장 중 오류 발생: $e');
      return null;
    }
  }

  /// 이미지 파일 삭제 (필요 시 호출)
  static Future<void> deleteImage(String uniqueFileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final filePath = path.join(appDir.path, uniqueFileName);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
