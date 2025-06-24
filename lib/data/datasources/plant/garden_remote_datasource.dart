import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tium/core/dio/api_client.dart';
import 'package:tium/data/models/plant/plant_detail_model.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:xml2json/xml2json.dart';

abstract class GardenRemoteDataSource {
  Future<List<PlantSummary>> list({int size, int? manageLevelCode});
  Future<PlantDetail> detail(String id, {required String name});
}

class GardenRemoteDataSourceImpl implements GardenRemoteDataSource {
  final ApiClient client;
  final Xml2Json _xml2json = Xml2Json();

  GardenRemoteDataSourceImpl(this.client);

  @override
  Future<List<PlantSummary>> list({int size = 300, int? manageLevelCode}) async {
    final query = {
      'pageNo': 1,
      'numOfRows': size,
    };
    if (manageLevelCode != null) {
      query['managelevelCode'] = manageLevelCode;
    }

    final res = await client.get('/garden/gardenList', query: query);

    _xml2json.parse(res.data as String);
    final jsonString = _xml2json.toParker();
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final itemsDynamic = jsonMap['response']?['body']?['items']?['item'];
    final items = itemsDynamic is List ? itemsDynamic : [itemsDynamic];

    final plants = <PlantSummary>[];

    for (final item in items) {
      final map = item as Map<String, dynamic>;
      final id = PlantSummary.getValue(map['cntntsNo']) ?? '';
      final highRes = await fetchHighResImage(id);
      plants.add(PlantSummary.fromIndoorGardenJson(map, highResImageUrl: highRes));
    }

    return plants;
  }


  @override
  Future<PlantDetail> detail(String id, {required String name}) async {
    final res = await client.get('/garden/gardenDtl', query: {'cntntsNo': id});
    _xml2json.parse(res.data as String);
    final jsonString = _xml2json.toGData();

    final jsonMap = jsonDecode(jsonString);
    final item = jsonMap['response']?['body']?['item'];

    // 고화질 이미지 추가로 fetch
    final highResImage = await fetchHighResImage(id);

    final mappedItem = Map<String, dynamic>.fromEntries(
      item.entries.map<MapEntry<String, dynamic>>(
            (e) => MapEntry(e.key.toString(), PlantDetail.getValue(e.value)),
      ),
    );

    return PlantDetail.fromIndoorGardenJson(mappedItem, highResImage: highResImage, name: name);
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
