import 'package:tium/data/models/location/juso_search_dto.dart';

abstract class JusoSearchRepository {
  Future<List<JusoSearchResult>> searchAddress(String keyword);
}
