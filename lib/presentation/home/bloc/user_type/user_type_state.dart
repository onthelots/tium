part of 'user_type_cubit.dart';

abstract class UserTypeState {}

class UserTypeInitial extends UserTypeState {}

class UserTypeLoading extends UserTypeState {}

class UserTypeLoaded extends UserTypeState {
  final UserTypeModel userTypeModel;
  UserTypeLoaded(this.userTypeModel);
}

class UserTypeError extends UserTypeState {
  final String message;
  UserTypeError(this.message);
}
