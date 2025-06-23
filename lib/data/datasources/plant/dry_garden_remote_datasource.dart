import 'dart:convert';
import 'package:tium/core/dio/api_client.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:xml2json/xml2json.dart';

/// 건조에 강한 식물 데이터소스 (XML only)
abstract class DryGardenRemoteDataSource {
  Future<List<PlantSummary>> list({int size});
  Future<PlantDetail> detail(String id);
}

class DryGardenRemoteDataSourceImpl implements DryGardenRemoteDataSource {
  final ApiClient client;
  final Xml2Json _xml2json = Xml2Json();

  DryGardenRemoteDataSourceImpl(this.client);

  @override
  Future<List<PlantSummary>> list({int size = 5}) async {
    final res = await client.get(
      '/dryGarden/dryGardenList',
      query: {
        'pageNo': 1,
        'numOfRows': size,
        // dataType 매개변수는 XML 전용이라 삭제
      },
    );

    // XML → JSON 변환
    _xml2json.parse(res.data as String);
    final jsonString = _xml2json.toParker(); // Parker 포맷이 가장 직관적
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final itemsDynamic = jsonMap['response']?['body']?['items']?['item'];
    final items = itemsDynamic is List ? itemsDynamic : [itemsDynamic];

    return items
        .map<PlantSummary>(
          (e) => PlantSummary.fromDryGardenJson(e as Map<String, dynamic>),
    )
        .toList();
  }

  @override
  Future<PlantDetail> detail(String id) async {
    final res = await client.get(
      '/dryGarden/dryGardenDtl',
      query: {
        'cntntsNo': id,
      },
    );

    _xml2json.parse(res.data as String);
    final jsonString = _xml2json.toParker();
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final item = jsonMap['response']?['body']?['item'];

    return PlantDetail.fromDryGardenJson(item as Map<String, dynamic>);
  }
}