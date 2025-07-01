import 'package:tium/data/models/user/user_model.dart';

abstract class UserPlantState {}

class UserPlantInitial extends UserPlantState {}

class UserPlantLoading extends UserPlantState {}

class UserPlantLoaded extends UserPlantState {
  final UserModel user;
  UserPlantLoaded(this.user);
}

class UserPlantError extends UserPlantState {
  final String message;
  UserPlantError(this.message);
}