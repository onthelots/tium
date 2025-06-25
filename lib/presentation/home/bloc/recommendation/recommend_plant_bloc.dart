import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/data/models/plant_preference/plant_preference.dart';
import 'package:tium/domain/usecases/plant/plants_usecase.dart';
import 'package:tium/presentation/home/bloc/recommendation/recommend_plant_event.dart';
import 'package:tium/presentation/home/bloc/recommendation/recommend_plant_state.dart';

class RecommendationBloc extends Bloc<RecommendationEvent, RecommendationState> {
  final GetRecommendedPlants getRecommendedPlants;

  RecommendationBloc(this.getRecommendedPlants) : super(RecommendationInitial()) {
    on<LoadUserRecommendations>(_onLoad);
  }

  Future<void> _onLoad(LoadUserRecommendations event, Emitter<RecommendationState> emit) async {
    emit(RecommendationLoading());
    try {
      final pref = userPlantPreferenceMap[event.userType]!;
      final results = await getRecommendedPlants(pref);
      emit(RecommendationLoaded(results));
    } catch (e) {
      emit(RecommendationError(e.toString()));
    }
  }
}