import 'package:equatable/equatable.dart';
import 'package:tium/data/models/user/user_model.dart'; // UserType Enum을 위해 임포트

/// Server에 저장된 UserType 상세 모델
class UserTypeModel extends Equatable {
  final int id;
  final String typeName;
  final String description;
  final String imageAsset;

  const UserTypeModel({
    required this.id,
    required this.typeName,
    required this.description,
    required this.imageAsset,
  });

  factory UserTypeModel.fromJson(Map<String, dynamic> json) {
    return UserTypeModel(
      id: json['id'] as int,
      typeName: json['type_name'] as String,
      description: json['description'] as String,
      imageAsset: json['image_asset'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_name': typeName,
      'description': description,
      'image_asset': imageAsset,
    };
  }

  UserType toEnum() {
    switch (id) {
      case 1: return UserType.sunnyLover;
      case 2: return UserType.quietCompanion;
      case 3: return UserType.smartSaver;
      case 4: return UserType.bloomingWatcher;
      case 5: return UserType.growthSeeker;
      case 6: return UserType.seasonalRomantic;
      case 7: return UserType.plantMaster;
      case 8: return UserType.calmObserver;
      case 9: return UserType.growthExplorer;
      default:
        throw ArgumentError('Invalid UserType ID: $id'); // 매칭되는 ID가 없으면 오류 발생
    }
  }

  @override
  List<Object?> get props => [id, typeName, description, imageAsset];
}




