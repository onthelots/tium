import 'package:tium/data/models/location/juso_search_dto.dart';
import 'package:tium/domain/repositories/location/juso_search_repository.dart';

class SearchAddressUseCase {
  final JusoSearchRepository repository;
  SearchAddressUseCase(this.repository);

  Future<List<JusoSearchResult>> call(String keyword) {
    return repository.searchAddress(keyword);
  }
}