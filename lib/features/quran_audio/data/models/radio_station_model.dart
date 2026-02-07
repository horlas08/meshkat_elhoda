import 'package:meshkat_elhoda/features/quran_audio/domain/entities/radio_station.dart';

class RadioStationModel extends RadioStation {
  const RadioStationModel({
    required super.id,
    required super.name,
    required super.url,
    required super.language,
    super.description,
    super.isActive = true,
  });

  factory RadioStationModel.fromJson(Map<String, dynamic> json) {
    // ✅ Fixed: Handle actual API response format
    // The API returns: { name, url, list, list_url }
    // We generate id as a hash of the URL for uniqueness
    final String name = json['name'] as String? ?? '';
    final String url = json['url'] as String? ?? '';
    final String listUrl = json['list_url'] as String? ?? '';

    // Generate ID from URL
    final String id = url.isEmpty
        ? name.hashCode.toString()
        : url.hashCode.toString();

    return RadioStationModel(
      id: id,
      name: name,
      url: url,
      language: 'ar', // ✅ Set to 'ar' since we're using radio_ar.json
      description: listUrl.isNotEmpty ? 'Has playlist' : null,
      isActive: url.isNotEmpty, // ✅ Mark as active if URL exists
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'language': language,
      'description': description,
      'active': isActive,
    };
  }

  RadioStationModel copyWith({
    String? id,
    String? name,
    String? url,
    String? language,
    String? description,
    bool? isActive,
  }) {
    return RadioStationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      language: language ?? this.language,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
