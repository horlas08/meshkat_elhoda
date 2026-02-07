import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationGranted extends LocationState {
  final LocationEntity location;

  const LocationGranted({required this.location});

  @override
  List<Object?> get props => [location];
}

class LocationDenied extends LocationState {
  final String message;

  const LocationDenied({
    this.message = 'Location permission denied. Please enable manually.',
  });

  @override
  List<Object?> get props => [message];
}

class ManualLocationRequested extends LocationState {}

class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object?> get props => [message];
}
