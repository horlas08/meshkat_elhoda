import 'package:meshkat_elhoda/features/halal_restaurants/domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.rating,
    super.userRatingsTotal,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location =
        geometry != null ? geometry['location'] as Map<String, dynamic>? : null;
    return RestaurantModel(
      id: (json['place_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      address: (json['vicinity'] ?? json['formatted_address'] ?? '').toString(),
      latitude:
          (location != null ? (location['lat'] as num?) : null)?.toDouble() ??
              0.0,
      longitude:
          (location != null ? (location['lng'] as num?) : null)?.toDouble() ??
              0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      userRatingsTotal: (json['user_ratings_total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
      'name': name,
      'vicinity': address,
      'place_id': id, // Ensure place_id is included
      'formatted_address': address, // Ensure formatted_address is included
      'rating': rating,
      'user_ratings_total': userRatingsTotal,
      'geometry': {
        'location': {
          'lat': latitude,
          'lng': longitude,
        },
      },
    };
  }
}
