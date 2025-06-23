import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationByAddressRequested extends LocationEvent {
  final String address;

  LocationByAddressRequested(this.address);

  @override
  List<Object?> get props => [address];
}

class LocationByLatLngRequested extends LocationEvent {
  final double lat;
  final double lng;

  LocationByLatLngRequested(this.lat, this.lng);

  @override
  List<Object?> get props => [lat, lng];
}
