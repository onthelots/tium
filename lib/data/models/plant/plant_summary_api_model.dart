import 'package:json_annotation/json_annotation.dart';
import 'package:tium/data/models/plant/plant_category_model.dart';

part 'plant_summary_api_model.g.dart';

// 식물 정보 (요약)
@JsonSerializable()
class PlantSummaryApiModel {
  final String id;
  final String name;
  final String imageUrl;
  final String? highResImageUrl;
  final PlantCategory category;

  const PlantSummaryApiModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.highResImageUrl,
    required this.category,
  });

  /// JSON 직렬화/역직렬화 지원
  factory PlantSummaryApiModel.fromJson(Map<String, dynamic> json) =>
      _$PlantSummaryApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlantSummaryApiModelToJson(this);

  /// XML 변환 JSON 대응용 생성자 (실내정원 전용)
  factory PlantSummaryApiModel.fromIndoorGardenJson(
      Map<String, dynamic> json, {
        String? highResImageUrl,
      }) {
    final rawUrls = getValue(json['rtnThumbFileUrl']) ?? '';
    final urls = rawUrls.split('|');
    final imageUrl = urls.isNotEmpty && urls.first.isNotEmpty ? urls.first : '';

    // TODO: - 일단 실내(indoor)로 지정함! (나중에 필요 시, 분기처리 할 것)
    return PlantSummaryApiModel(
      id: getValue(json['cntntsNo']) ?? '',
      name: getValue(json['cntntsSj']) ?? '',
      imageUrl: imageUrl,
      highResImageUrl: highResImageUrl ?? imageUrl,
      category: PlantCategory.indoorGarden,
    );
  }

  /// XML CDATA 또는 일반 텍스트 노드에서 값 추출
  static String? getValue(dynamic node) {
    if (node == null) return null;
    if (node is String) return node;
    if (node is Map<String, dynamic>) {
      return node['__cdata']?.toString() ?? node['\$t']?.toString();
    }
    return null;
  }
}
