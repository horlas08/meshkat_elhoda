import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meshkat_elhoda/features/halal_restaurants/data/models/restaurant_model.dart';

abstract class HalalRestaurantsRemoteDataSource {
  Future<List<RestaurantModel>> getNearbyHalalRestaurants({
    required double latitude,
    required double longitude,
    int radiusInMeters = 5000,
  });
}

class HalalRestaurantsRemoteDataSourceImpl
    implements HalalRestaurantsRemoteDataSource {
  final http.Client client;
  // Use same API key as Mosques
  static const String _apiKey = 'AIzaSyDmgxQIRDwTzrU6ph702YXadBPLSzv2pnc';

  HalalRestaurantsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<RestaurantModel>> getNearbyHalalRestaurants({
    required double latitude,
    required double longitude,
    int radiusInMeters = 5000,
  }) async {
    // Uses Text Search for better "Halal" matching
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/textsearch/json'
      '?query=halal+restaurant&location=$latitude,$longitude&radius=$radiusInMeters&key=$_apiKey',
    );

    final res = await client.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch restaurants: ${res.statusCode}');
    }

    final decoded = json.decode(res.body) as Map<String, dynamic>;

    if (decoded['status'] != 'OK' && decoded['status'] != 'ZERO_RESULTS') {
      throw Exception(
        'Google API Error: ${decoded['status']} - ${decoded['error_message'] ?? 'Unknown error'}',
      );
    }

    final results = (decoded['results'] as List<dynamic>? ?? []);
    return results
        .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
