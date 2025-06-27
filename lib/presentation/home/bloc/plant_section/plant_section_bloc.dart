import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/data/models/plant_preference/plant_preference.dart';
import 'package:tium/domain/entities/plant/plant_section.dart';
import 'package:tium/domain/usecases/plant/plants_usecase.dart';
import 'package:tium/presentation/home/bloc/plant_section/plant_section_event.dart';
import 'package:tium/presentation/home/bloc/plant_section/plant_section_state.dart';

class RecommendationSectionBloc extends Bloc<RecommendationSectionEvent, RecommendationSectionState> {
  final GetRecommendedPlantsByFilter getPlantsByFilter;

  RecommendationSectionBloc(this.getPlantsByFilter) : super(RecommendationSectionInitial()) {
    on<LoadUserRecommendationsSections>(_onLoad);
  }

  Future<void> _onLoad(
      LoadUserRecommendationsSections event,
      Emitter<RecommendationSectionState> emit,
      ) async {
    emit(RecommendationSectionLoading());
    print('[RecommendationSectionBloc] _onLoad started for userType: ${event.userType}');

    try {
      final sectionsData = userRecommendationSectionsReduced[event.userType]; // ✅ 여기만 변경
      print('[RecommendationSectionBloc] sectionsData count: ${sectionsData?.length ?? 0}');

      if (sectionsData == null || sectionsData.isEmpty) {
        print('[RecommendationSectionBloc] No sections found, emitting empty list');
        emit(RecommendationSectionLoaded([]));
        return;
      }

      final List<PlantSection> sections = [];

      for (final section in sectionsData) {
        final title = section.title;
        final filter = section.filter;
        final limit = section.limit;

        final plants = await getPlantsByFilter.call(filter, size: limit);

        if (plants.isNotEmpty) {
          sections.add(
            PlantSection(title, plants, filter: filter), // filter 추가 (더보기 화면에 전달)
          );
        }
      }

      print('[RecommendationSectionBloc] Loaded total ${sections.length} sections, emitting loaded state');
      emit(RecommendationSectionLoaded(sections));
    } catch (e, stack) {
      print('[RecommendationSectionBloc] Error occurred: $e');
      print(stack);
      emit(RecommendationSectionError(e.toString()));
    }
  }
}
