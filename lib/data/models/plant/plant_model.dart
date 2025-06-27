
// 식물 카테고리
enum PlantCategory {
  indoorGarden,
  dryGarden,
}

// 난이도
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  unknown,
}

// 생육 속도
enum GrowthSpeed {
  slow,
  medium,
  fast,
  unknown,
}

// 물주기 타입
enum WateringType {
  alwaysWet,           // 053001
  keepMoist,           // 053002
  whenSurfaceDries,    // 053003
  whenMostlyDries,     // 053004
  droughtTolerant,     // dryGarden only
  unknown,
}

// 물주기 정보
class WateringInfo {
  final String description;
  final int minDays;
  final int maxDays;
  final WateringType type;

  const WateringInfo({
    required this.description,
    required this.minDays,
    required this.maxDays,
    required this.type,
  });
}

// 식물 정보 (요약)
class PlantSummary {
  final String id;
  final String name;
  final String imageUrl;
  final String? highResImageUrl;
  final PlantCategory category;

  const PlantSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.highResImageUrl,
    required this.category,
  });

  // 공통 CDATA / 텍스트 파서
  static String? getValue(dynamic node) {
    if (node == null) return null;
    if (node is String) return node;
    if (node is Map) {
      if (node.containsKey('__cdata')) return node['__cdata']?.toString();
      if (node.containsKey('\$t')) return node['\$t']?.toString();
    }
    return null;
  }

  // 건조 식물용 (mainImgUrl1)
  factory PlantSummary.fromDryGardenJson(Map<String, dynamic> json) {
    return PlantSummary(
      id: getValue(json['cntntsNo']) ?? '',
      name: getValue(json['cntntsSj']) ?? '',
      imageUrl: getValue(json['mainImgUrl1']) ?? getValue(json['imgUrl1']) ?? '',
      category: PlantCategory.dryGarden,  // 여기서 명확히 지정
    );
  }

  // 실내 정원용 (rtnThumbFileUrl)
  factory PlantSummary.fromIndoorGardenJson(Map<String, dynamic> json, {String? highResImageUrl}) {
    final rawUrls = getValue(json['rtnThumbFileUrl']) ?? '';
    final urls = rawUrls.split('|');
    final imageUrl = urls.isNotEmpty && urls.first.isNotEmpty ? urls.first : '';

    return PlantSummary(
      id: getValue(json['cntntsNo']) ?? '',
      name: getValue(json['cntntsSj']) ?? '',
      imageUrl: imageUrl,
      highResImageUrl: highResImageUrl ?? imageUrl,
      category: PlantCategory.indoorGarden,  // 여기서 명확히 지정
    );
  }
}
