// 2. DATASOURCE
import 'dart:convert';

import 'package:tium/core/dio/api_client.dart';
import 'package:tium/data/models/location/juso_search_dto.dart';

abstract class JusoSearchRemoteDataSource {
  Future<List<JusoSearchResult>> search(
      String keyword, {
        int page,
        int size,
      });
}

class JusoSearchRemoteDataSourceImpl implements JusoSearchRemoteDataSource {
  final ApiClient client;

  JusoSearchRemoteDataSourceImpl(this.client);

  @override
  Future<List<JusoSearchResult>> search(
      String keyword, {
        int page = 1,
        int size = 20,
      }) async {
    final res = await client.get(
      '', // baseUrl에 addrLinkApi.do 포함되어 있으므로 빈 path
      query: {
        'keyword': keyword,
        'currentPage': page.toString(),
        'countPerPage': size.toString(),
      },
    );

    print('🔍 API 응답 데이터 raw: ${res.data}'); // 전체 raw 응답 로그 출력

    final body = jsonDecode(res.data);

    final errorCode = body['results']?['common']?['errorCode'];
    final errorMessage = body['results']?['common']?['errorMessage'];

    print('🔍 API errorCode: $errorCode, errorMessage: $errorMessage');

    if (errorCode != '0') {
      throw Exception('API Error: $errorMessage');
    }

    final jusoList = body['results']?['juso'] ?? [];

    print('🔍 검색 결과 개수: ${jusoList.length}');

    return List<JusoSearchResult>.from(
      jusoList.map((e) => JusoSearchResult.fromJson(e)),
    );
  }
}
