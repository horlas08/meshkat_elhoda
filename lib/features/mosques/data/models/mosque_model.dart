import 'package:meshkat_elhoda/features/mosques/domain/entities/mosque.dart';

class MosqueModel extends Mosque {
  const MosqueModel({
    required super.id,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
  });

  factory MosqueModel.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry != null ? geometry['location'] as Map<String, dynamic>? : null;
    return MosqueModel(
      id: (json['place_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      address: (json['vicinity'] ?? json['formatted_address'] ?? '').toString(),
      latitude: (location != null ? (location['lat'] as num?) : null)?.toDouble() ?? 0.0,
      longitude: (location != null ? (location['lng'] as num?) : null)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
      'name': name,
      'vicinity': address,
      'geometry': {
        'location': {
          'lat': latitude,
          'lng': longitude,
        },
      },
    };
  }
}
