import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class RequestLocationPermissionEvent extends LocationEvent {}

class GetCurrentLocationEvent extends LocationEvent {}

class SetManualLocation extends LocationEvent {
  final String city;
  final String country;

  const SetManualLocation({required this.city, required this.country});

  @override
  List<Object?> get props => [city, country];
}

class LoadStoredLocation extends LocationEvent {}

class UpdateLocation extends LocationEvent {
  final LocationEntity location;

  const UpdateLocation({required this.location});

  @override
  List<Object?> get props => [location];
}

class ClearLocation extends LocationEvent {}

/// حدث للتحقق من الحاجة لتحديث الموقع تلقائياً
class RefreshLocationIfNeeded extends LocationEvent {
  final bool forceRefresh;

  const RefreshLocationIfNeeded({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class StartLocationUpdates extends LocationEvent {}

class StopLocationUpdates extends LocationEvent {}
