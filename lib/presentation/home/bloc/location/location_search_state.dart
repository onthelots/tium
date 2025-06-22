import 'package:equatable/equatable.dart';
import 'package:tium/data/models/user/user_model.dart';

abstract class LocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoadInProgress extends LocationState {}

class LocationLoadSuccess extends LocationState {
  final UserLocation location;

  LocationLoadSuccess(this.location);

  @override
  List<Object?> get props => [location];
}

class LocationLoadFailure extends LocationState {
  final String message;

  LocationLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
