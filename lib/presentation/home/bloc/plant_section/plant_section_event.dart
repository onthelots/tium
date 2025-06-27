import 'package:tium/data/models/user/user_model.dart';

sealed class RecommendationSectionEvent {}

class LoadUserRecommendationsSections extends RecommendationSectionEvent {
  final UserType userType;
  LoadUserRecommendationsSections({required this.userType});
}
