enum PlantCategory { dryGarden, indoorGarden, beginner }

class PlantSummary {
  final String id;
  final String name;
  final String imageUrl;

  const PlantSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // 건조 식물용 (imgUrl1 사용)
  factory PlantSummary.fromDryGardenJson(Map<String, dynamic> json) {
    return PlantSummary(
      id: json['cntntsNo']?.toString() ?? '',
      name: json['cntntsSj'] ?? '',
      imageUrl: json['imgUrl1'] ?? '',
    );
  }

  // 실내 정원용 (rtnThumbFileUrl 첫번째 URL 사용)
  factory PlantSummary.fromIndoorGardenJson(Map<String, dynamic> json) {
    final urls = (json['rtnThumbFileUrl'] as String?)?.split('|') ?? [];
    final imageUrl = urls.isNotEmpty ? urls[0] : '';

    return PlantSummary(
      id: json['cntntsNo']?.toString() ?? '',
      name: json['cntntsSj'] ?? '',
      imageUrl: imageUrl,
    );
  }
}

class PlantDetail {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  const PlantDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory PlantDetail.fromDryGardenJson(Map<String, dynamic> json) {
    return PlantDetail(
      id: json['cntntsNo']?.toString() ?? '',
      name: json['cntntsSj'] ?? '',
      description: json['mainChartrInfo'] ?? '',
      imageUrl: json['imgUrl1'] ?? '',
    );
  }

  factory PlantDetail.fromIndoorGardenJson(Map<String, dynamic> json) {
    final urls = (json['rtnThumbFileUrl'] as String?)?.split('|') ?? [];
    final imageUrl = urls.isNotEmpty ? urls[0] : '';

    return PlantDetail(
      id: json['cntntsNo']?.toString() ?? '',
      name: json['cntntsSj'] ?? '',
      description: json['mainChartrInfo'] ?? '',
      imageUrl: imageUrl,
    );
  }
}
