import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meshkat_elhoda/core/error/exceptions.dart';

class QuranApiService {
  final http.Client _client;
  final String _baseUrl = 'https://api.quran.com/api/v4';

  QuranApiService(this._client);

  Future<Map<String, dynamic>> getSurahs() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/chapters'),
        headers: {'Accept': 'application/json'},
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    try {
      final uri = Uri.parse('$_baseUrl/verses/by_chapter/$surahNumber').replace(
        queryParameters: {
          'language': 'ar',
          'words': 'true',
          'page': '1',
          'per_page': '300', // Assuming no surah has more than 300 verses
        },
      );

      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getVerse(int surahNumber, int verseNumber) async {
    try {
      final uri = Uri.parse('$_baseUrl/verses/by_key/$surahNumber:$verseNumber').replace(
        queryParameters: {
          'language': 'ar',
          'words': 'true',
        },
      );

      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw ServerException(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  ServerException _handleError(dynamic error) {
    if (error is ServerException) {
      return error;
    }
    return ServerException(
      message: error.toString(),
      statusCode: 500,
    );
  }
}
