import 'package:tium/data/datasources/location/juso_search_remote_datasource.dart';
import 'package:tium/data/models/location/juso_search_dto.dart';
import 'package:tium/domain/repositories/location/juso_search_repository.dart';

class JusoSearchRepositoryImpl implements JusoSearchRepository {
  final JusoSearchRemoteDataSource remote;
  JusoSearchRepositoryImpl(this.remote);

  @override
  Future<List<JusoSearchResult>> searchAddress(String keyword) {
    return remote.search(keyword);
  }
}