import 'package:equatable/equatable.dart';

enum LocationMethod { gps, manual }

class LocationEntity extends Equatable {
  final LocationMethod method;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String timezone;
  final DateTime timestamp;

  const LocationEntity({
    required this.method,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    required this.timezone,
    required this.timestamp,
  });

  bool get isGPS => method == LocationMethod.gps;
  bool get isManual => method == LocationMethod.manual;

  @override
  List<Object?> get props => [
        method,
        latitude,
        longitude,
        city,
        country,
        timezone,
        timestamp,
      ];
}
