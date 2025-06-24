import 'package:tium/data/models/plant/plant_model.dart';

class PlantDetail {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String? originPlace;
  final String? growthInfo;
  final String? careLevel;
  final String? wateringInfo;
  final String? propagationMethod;
  final String? sunlightInfo;
  final DifficultyLevel difficultyLevel;
  final GrowthSpeed growthSpeed;

  const PlantDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.originPlace,
    this.growthInfo,
    this.careLevel,
    this.wateringInfo,
    this.propagationMethod,
    this.sunlightInfo,
    required this.difficultyLevel,
    required this.growthSpeed,
  });

  static String? getValue(dynamic node) {
    if (node == null) return null;
    if (node is String) return node;
    if (node is Map) {
      if (node.containsKey('__cdata')) return node['__cdata']?.toString();
      if (node.containsKey('\$t')) return node['\$t']?.toString();
    }
    return null;
  }

  factory PlantDetail.fromDryGardenJson(Map<String, dynamic> json) {
    final rawDifficultyCode = getValue(json['manageLevelNm']);
    final rawGrowthSpeed = getValue(json['grwtseVeNm']);

    return PlantDetail(
      id: getValue(json['cntntsNo']) ?? '',
      name: getValue(json['cntntsSj']) ?? '',
      description: getValue(json['mainChartrInfo']) ?? getValue(json['fncltyInfo']) ?? '',
      imageUrl: getValue(json['mainImgUrl1']) ?? getValue(json['lightImgUrl1']) ?? '',
      originPlace: getValue(json['orgplce']),
      growthInfo: getValue(json['grwtInfo']),
      careLevel: getValue(json['manageLevelNm']),
      wateringInfo: getValue(json['watercycle']),
      propagationMethod: getValue(json['prpgtInfo']),
      sunlightInfo: getValue(json['lighttInfo']),
      difficultyLevel: mapDifficultyCode(rawDifficultyCode, PlantCategory.dryGarden),
      growthSpeed: mapGrowthSpeed(rawGrowthSpeed),
    );
  }

  factory PlantDetail.fromIndoorGardenJson(
      Map<String, dynamic> json, {
        required String name, // 외부에서 Summary의 이름을 넘겨줌
        String? highResImage,
      }) {
    final imageUrl = highResImage ??
        ((getValue(json['rtnThumbFileUrl']) ?? '').split('|').firstOrNull ?? '');

    final rawDifficultyCode = getValue(json['managelevelCodeNm']) ?? getValue(json['manageLevelNm']);
    final rawGrowthSpeed = getValue(json['grwtveCodeNm']) ?? getValue(json['grwtseVeNm']);

    return PlantDetail(
      id: getValue(json['cntntsNo']) ?? '',
      name: name,
      description: getValue(json['mainChartrInfo']) ?? getValue(json['fncltyInfo']) ?? '',
      imageUrl: imageUrl,
      originPlace: getValue(json['distbNm']) ?? getValue(json['orgplceInfo']),
      growthInfo: getValue(json['grwhTpCodeNm']) ?? getValue(json['grwhTpInfo']),
      careLevel: rawDifficultyCode,
      wateringInfo: getValue(json['watercycleWinterCodeNm']) ?? getValue(json['watercycle']),
      propagationMethod: getValue(json['prpgtmthCodeNm']) ?? getValue(json['prpgtInfo']),
      sunlightInfo: getValue(json['lighttdemanddoCodeNm']) ?? getValue(json['lighttInfo']),
      difficultyLevel: mapDifficultyCode(rawDifficultyCode, PlantCategory.indoorGarden),
      growthSpeed: mapGrowthSpeed(rawGrowthSpeed),
    );
  }
}

// 난이도 코드별 매핑 함수
DifficultyLevel mapDifficultyCode(String? code, PlantCategory category) {
  if (code == null) return DifficultyLevel.unknown;

  switch (category) {
    case PlantCategory.indoorGarden:
      switch (code.trim()) {
        case '초보자': return DifficultyLevel.beginner;
        case '경험자': return DifficultyLevel.intermediate;
        case '전문가': return DifficultyLevel.advanced;
      }
      break;

    case PlantCategory.dryGarden:
      switch (code.trim()) {
        case '매우 쉬움':
        case '쉬움':
          return DifficultyLevel.beginner;
        case '보통':
          return DifficultyLevel.intermediate;
        case '어려움':
        case '매우 어려움':
          return DifficultyLevel.advanced;
      }
      break;
  }

  return DifficultyLevel.unknown;
}


// 성장속도 코드/문자열 매핑 함수
GrowthSpeed mapGrowthSpeed(String? speedStr) {
  if (speedStr == null) return GrowthSpeed.unknown;

  final lowered = speedStr.toLowerCase();

  if (lowered.contains('느림')) return GrowthSpeed.slow;
  if (lowered.contains('보통') || lowered.contains('중간')) return GrowthSpeed.medium;
  if (lowered.contains('빠름') || lowered.contains('빠르다')) return GrowthSpeed.fast;

  return GrowthSpeed.unknown;
}