import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meshkat_elhoda/features/mosques/data/models/mosque_model.dart';

abstract class MosquesRemoteDataSource {
  Future<List<MosqueModel>> getNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusInMeters = 3000,
  });
}

class MosquesRemoteDataSourceImpl implements MosquesRemoteDataSource {
  final http.Client client;
  // ضع الـ API key مباشرة كـ constant
  static const String _apiKey = 'AIzaSyDmgxQIRDwTzrU6ph702YXadBPLSzv2pnc';

  MosquesRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MosqueModel>> getNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusInMeters = 3000,
  }) async {
    // إزالة التحقق من وجود API key طالما هي موجودة مباشرة
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$latitude,$longitude&radius=$radiusInMeters&type=mosque&key=$_apiKey',
    );

    final res = await client.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch mosques: ${res.statusCode}');
    }

    final decoded = json.decode(res.body) as Map<String, dynamic>;

    // تحقق من وجود errors من Google API
    if (decoded['status'] != 'OK') {
      throw Exception(
        'Google API Error: ${decoded['status']} - ${decoded['error_message'] ?? 'Unknown error'}',
      );
    }

    final results = (decoded['results'] as List<dynamic>? ?? []);
    return results
        .map((e) => MosqueModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
