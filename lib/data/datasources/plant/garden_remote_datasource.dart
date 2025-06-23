import 'dart:convert';
import 'package:tium/core/dio/api_client.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:xml2json/xml2json.dart';

abstract class GardenRemoteDataSource {
  Future<List<PlantSummary>> list({int size, int? manageLevelCode});
  Future<PlantDetail> detail(String id);
}

class GardenRemoteDataSourceImpl implements GardenRemoteDataSource {
  final ApiClient client;
  final Xml2Json _xml2json = Xml2Json();

  GardenRemoteDataSourceImpl(this.client);

  @override
  Future<List<PlantSummary>> list({int size = 5, int? manageLevelCode}) async {
    final query = {
      'pageNo': 1,
      'numOfRows': size,
      // 'dataType': 'JSON', // 삭제: 응답은 XML
    };
    if (manageLevelCode != null) {
      query['managelevelCode'] = manageLevelCode;
    }

    final res = await client.get('/garden/gardenList', query: query);

    // XML → JSON
    _xml2json.parse(res.data as String);
    final jsonString = _xml2json.toParker();
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final itemsDynamic = jsonMap['response']?['body']?['items']?['item'];
    final items = itemsDynamic is List ? itemsDynamic : [itemsDynamic];

    return items
        .map<PlantSummary>(
          (e) => PlantSummary.fromIndoorGardenJson(e as Map<String, dynamic>),
    )
        .toList();
  }

  @override
  Future<PlantDetail> detail(String id) async {
    final res = await client.get('/garden/gardenDtl', query: {
      'cntntsNo': id,
    });

    _xml2json.parse(res.data as String);
    final jsonString = _xml2json.toParker();
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final item = jsonMap['response']?['body']?['item'];

    return PlantDetail.fromIndoorGardenJson(item as Map<String, dynamic>);
  }
}
