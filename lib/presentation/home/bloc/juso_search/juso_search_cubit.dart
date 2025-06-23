import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/data/models/location/juso_search_dto.dart';
import 'package:tium/domain/usecases/location/juso_search_usecase.dart';

sealed class JusoSearchState {}

/// State
class JusoSearchInitial extends JusoSearchState {}
class JusoSearchLoading extends JusoSearchState {}

class JusoSearchLoaded extends JusoSearchState {
  final List<JusoSearchResult> results;
  JusoSearchLoaded(this.results);
}

class JusoSearchError extends JusoSearchState {
  final String message;
  JusoSearchError(this.message);
}

/// Cubit
class JusoSearchCubit extends Cubit<JusoSearchState> {

  final SearchAddressUseCase searchUseCase;
  JusoSearchCubit(this.searchUseCase) : super(JusoSearchInitial());

  Future<void> search(String keyword) async {
    emit(JusoSearchLoading());
    try {
      final results = await searchUseCase(keyword);
      emit(JusoSearchLoaded(results));
    } catch (e) {
      emit(JusoSearchError('검색 실패: $e'));
    }
  }
}