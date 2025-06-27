import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/data/models/plant_preference/plant_preference.dart';
import 'package:tium/domain/usecases/plant/plants_usecase.dart';
import 'package:tium/presentation/onboarding/bloc/recommendation/recommend_plant_event.dart';
import 'package:tium/presentation/onboarding/bloc/recommendation/recommend_plant_state.dart';

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

      print("나에게 맞는 추천 식물은? : ${results.length}");

      emit(RecommendationLoaded(results));
    } catch (e) {
      emit(RecommendationError(e.toString()));
    }
  }
}