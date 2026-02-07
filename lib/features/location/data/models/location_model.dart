import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.method,
    super.latitude,
    super.longitude,
    super.city,
    super.country,
    required super.timezone,
    required super.timestamp,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      method: json['method'] == 'gps'
          ? LocationMethod.gps
          : LocationMethod.manual,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method == LocationMethod.gps ? 'gps' : 'manual',
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'timezone': timezone,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      method: entity.method,
      latitude: entity.latitude,
      longitude: entity.longitude,
      city: entity.city,
      country: entity.country,
      timezone: entity.timezone,
      timestamp: entity.timestamp,
    );
  }

  LocationModel copyWith({
    LocationMethod? method,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? timezone,
    DateTime? timestamp,
  }) {
    return LocationModel(
      method: method ?? this.method,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
