import 'package:tium/data/models/plant/plant_model.dart';

class PlantDetail {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String? originPlace;
  final String? growthInfo;
  final String? careLevel;
  final WateringInfo wateringInfo;
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
    required this.wateringInfo,
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
    final rawWateringText = getValue(json['waterCycleInfo']);

    return PlantDetail(
      id: getValue(json['cntntsNo']) ?? '',
      name: getValue(json['cntntsSj']) ?? '',
      description: getValue(json['mainChartrInfo']) ?? getValue(json['fncltyInfo']) ?? '',
      imageUrl: getValue(json['mainImgUrl1']) ?? getValue(json['lightImgUrl1']) ?? '',
      originPlace: getValue(json['orgplce']),
      growthInfo: getValue(json['grwtInfo']),
      careLevel: getValue(json['manageLevelNm']),
      wateringInfo: mapWateringInfo(
        category: PlantCategory.dryGarden,
        description: rawWateringText,
      ),
      propagationMethod: getValue(json['prpgtInfo']),
      sunlightInfo: getValue(json['lighttInfo']),
      difficultyLevel: mapDifficultyCode(rawDifficultyCode, PlantCategory.dryGarden),
      growthSpeed: mapGrowthSpeed(rawGrowthSpeed),
    );
  }

  factory PlantDetail.fromIndoorGardenJson(
      Map<String, dynamic> json, {
        required String name,
        String? highResImage,
      }) {
    final imageUrl = highResImage ??
        ((getValue(json['rtnThumbFileUrl']) ?? '').split('|').firstOrNull ?? '');

    final rawDifficultyCode = getValue(json['managelevelCodeNm']) ?? getValue(json['manageLevelNm']);
    final rawGrowthSpeed = getValue(json['grwtveCodeNm']) ?? getValue(json['grwtseVeNm']);
    final rawWateringCode = getValue(json['watercycleSummerCode']);
    final rawWateringText = getValue(json['watercycleSummerCodeNm']);

    return PlantDetail(
      id: getValue(json['cntntsNo']) ?? '',
      name: name,
      description: getValue(json['mainChartrInfo']) ?? getValue(json['fncltyInfo']) ?? '',
      imageUrl: imageUrl,
      originPlace: getValue(json['distbNm']) ?? getValue(json['orgplceInfo']),
      growthInfo: getValue(json['grwhTpCodeNm']) ?? getValue(json['grwhTpInfo']),
      careLevel: rawDifficultyCode,
      wateringInfo: mapWateringInfo(
        category: PlantCategory.indoorGarden,
        code: rawWateringCode,
        description: rawWateringText,
      ),
      propagationMethod: getValue(json['prpgtmthCodeNm']) ?? getValue(json['prpgtInfo']),
      sunlightInfo: getValue(json['lighttdemanddoCodeNm']) ?? getValue(json['lighttInfo']),
      difficultyLevel: mapDifficultyCode(rawDifficultyCode, PlantCategory.indoorGarden),
      growthSpeed: mapGrowthSpeed(rawGrowthSpeed),
    );
  }
}

String cleanHtml(String? html) {
  if (html == null) return '';
  return html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n') // <br>, <br/> → 줄바꿈
      .replaceAll(RegExp(r'<[^>]*>'), '') // 다른 모든 태그 제거
      .trim(); // 앞뒤 공백 제거
}

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

GrowthSpeed mapGrowthSpeed(String? speedStr) {
  if (speedStr == null) return GrowthSpeed.unknown;

  final lowered = speedStr.toLowerCase();

  if (lowered.contains('느림')) return GrowthSpeed.slow;
  if (lowered.contains('보통') || lowered.contains('중간')) return GrowthSpeed.medium;
  if (lowered.contains('빠름') || lowered.contains('빠르다')) return GrowthSpeed.fast;

  return GrowthSpeed.unknown;
}

WateringInfo mapWateringInfo({
  required PlantCategory category,
  String? code,
  String? description,
}) {
  final cleanedDescription = cleanHtml(description);

  if (category == PlantCategory.indoorGarden) {
    switch (code?.trim()) {
      case '053001':
        return WateringInfo(
          description: cleanedDescription.isNotEmpty ? cleanedDescription : '항상 흙을 축축하게 유지',
          minDays: 1,
          maxDays: 2,
          type: WateringType.alwaysWet,
        );
      case '053002':
        return WateringInfo(
          description: cleanedDescription.isNotEmpty ? cleanedDescription : '흙을 촉촉하게 유지',
          minDays: 3,
          maxDays: 4,
          type: WateringType.keepMoist,
        );
      case '053003':
        return WateringInfo(
          description: cleanedDescription.isNotEmpty ? cleanedDescription : '토양 표면이 말랐을 때 충분히 관수',
          minDays: 5,
          maxDays: 6,
          type: WateringType.whenSurfaceDries,
        );
      case '053004':
        return WateringInfo(
          description: cleanedDescription.isNotEmpty ? cleanedDescription : '화분 흙 대부분 말랐을 때 충분히 관수',
          minDays: 7,
          maxDays: 10,
          type: WateringType.whenMostlyDries,
        );
    }

    return WateringInfo(
      description: cleanedDescription.isNotEmpty ? cleanedDescription : '물주기 정보 없음',
      minDays: 0,
      maxDays: 0,
      type: WateringType.unknown,
    );
  }

  // dryGarden
  return WateringInfo(
    description: cleanedDescription.isNotEmpty ? cleanedDescription : '건조한 환경에 강해 자주 물을 줄 필요가 없습니다',
    minDays: 15,
    maxDays: 30,
    type: WateringType.droughtTolerant,
  );
}

