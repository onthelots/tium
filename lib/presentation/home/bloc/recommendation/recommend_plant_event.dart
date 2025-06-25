import 'package:tium/data/models/user/user_model.dart';

sealed class RecommendationEvent {}

class LoadUserRecommendations extends RecommendationEvent {
  final UserType userType;
  LoadUserRecommendations({required this.userType});
}