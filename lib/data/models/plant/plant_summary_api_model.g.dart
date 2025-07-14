// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_summary_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantSummaryApiModel _$PlantSummaryApiModelFromJson(
        Map<String, dynamic> json) =>
    PlantSummaryApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      highResImageUrl: json['highResImageUrl'] as String?,
      category: $enumDecode(_$PlantCategoryEnumMap, json['category']),
    );

Map<String, dynamic> _$PlantSummaryApiModelToJson(
        PlantSummaryApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'highResImageUrl': instance.highResImageUrl,
      'category': _$PlantCategoryEnumMap[instance.category]!,
    };

const _$PlantCategoryEnumMap = {
  PlantCategory.indoorGarden: 'indoorGarden',
  PlantCategory.dryGarden: 'dryGarden',
};
