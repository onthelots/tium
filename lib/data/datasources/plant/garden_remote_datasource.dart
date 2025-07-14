import 'dart:convert';
import 'package:tium/core/dio/api_client.dart';
import 'package:tium/data/models/plant/plant_detail_api_model.dart'; // Import new API model
import 'package:tium/data/models/plant/plant_summary_api_model.dart'; // Keep PlantSummary for now
import 'package:xml2json/xml2json.dart';

abstract class GardenRemoteDataSource {
  Future<List<PlantSummaryApiModel>> list({
    int? size,
    String? lightChkVal,
    String? lefcolrChkVal,
    String? grwhstleChkVal,
    String? ignSeasonChkVal,
    String? priceType,
    String? waterCycleSel,
  });
  Future<PlantDetailApiModel> detail(String id); // Change return type
}

class GardenRemoteDataSourceImpl implements GardenRemoteDataSource {
  final ApiClient client;
  final Xml2Json _xml2json = Xml2Json();

  GardenRemoteDataSourceImpl(this.client);

  @override
  Future<List<PlantSummaryApiModel>> list({
    int? size,
    String? lightChkVal,
    String? lefcolrChkVal,
    String? grwhstleChkVal,
    String? ignSeasonChkVal,
    String? priceType,
    String? waterCycleSel,
  }) async {
    final Map<String, dynamic> query = {
      'pageNo': 1,
      'numOfRows': size,
    };

    if (lightChkVal != null) query['lightChkVal'] = lightChkVal;
    if (lefcolrChkVal != null) query['lefcolrChkVal'] = lefcolrChkVal;
    if (grwhstleChkVal != null) query['grwhstleChkVal'] = grwhstleChkVal;
    if (ignSeasonChkVal != null) query['ignSeasonChkVal'] = ignSeasonChkVal;
    if (priceType != null) query['priceType'] = priceType;
    if (waterCycleSel != null) query['waterCycleSel'] = waterCycleSel;

    final res = await client.get('/garden/gardenList', query: query);

    _xml2json.parse(res.data as String);
    final jsonString = _xml2json.toParker();
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final itemsDynamic = jsonMap['response']?['body']?['items']?['item'];
    if (itemsDynamic == null) return [];

    final items = itemsDynamic is List ? itemsDynamic : [itemsDynamic];

    final plants = <PlantSummaryApiModel>[];

    for (final item in items) {
      final map = item as Map<String, dynamic>;
      final id = PlantSummaryApiModel.getValue(map['cntntsNo']) ?? '';
      final highRes = await fetchHighResImage(id);
      plants.add(PlantSummaryApiModel.fromIndoorGardenJson(map, highResImageUrl: highRes));
    }

    return plants;
  }

  @override
  Future<PlantDetailApiModel> detail(String id) async {
    final res = await client.get('/garden/gardenDtl', query: {'cntntsNo': id});
    _xml2json.parse(res.data as String);
    final jsonString = _xml2json.toParker(); // 또는 toGData() 사용 시 일관성 있게 선택

    final jsonMap = jsonDecode(jsonString);
    final item = jsonMap['response']?['body']?['item'];

    if (item == null) {
      throw Exception('No detail found for id: $id');
    }

    return PlantDetailApiModel.fromXmlJson(item as Map<String, dynamic>);
  }

  Future<String?> fetchHighResImage(String id) async {
    final res = await client.get(
      '/garden/gardenFileList',
      query: {'cntntsNo': id},
    );

    _xml2json.parse(res.data as String);
    final jsonString = _xml2json.toParker();
    final jsonMap = jsonDecode(jsonString);

    final items = jsonMap['response']?['body']?['items']?['item'];
    final itemList = items is List ? items : [items];

    // 일반 이미지 찾기
    for (final item in itemList) {
      final map = item as Map<String, dynamic>;
      final fileType = map['rtnFileSeCodeName'];
      if (fileType == '이미지') {
        final url = map['rtnFileUrl'];
        if (url is String && url.isNotEmpty) return url;
      }
    }

    return null;
  }
}