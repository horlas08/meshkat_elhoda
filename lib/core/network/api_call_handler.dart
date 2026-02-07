import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meshkat_elhoda/core/error/exceptions.dart';

/// أنواع واجهات برمجة التطبيقات المتاحة
enum ApiType {
  quran,
  hadith,
  tafseer,
}

/// معالج المكالمات للواجهات البرمجية الخارجية
class ApiCallHandler {
  final http.Client _client;
  final Map<ApiType, String> _baseUrls = {
    ApiType.quran: 'https://api.quran.com/api/v4',
    ApiType.hadith: 'https://api.sunnah.com/v1',
    ApiType.tafseer: 'https://api.quran-tafseer.com',
  };

  /// إنشاء مثيل جديد من معالج المكالمات
  ApiCallHandler({required http.Client client}) : _client = client;

  /// تنفيذ طلب GET
  Future<Map<String, dynamic>> get(
    ApiType type,
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      type: type,
      endpoint: endpoint,
      method: 'GET',
      queryParams: queryParams,
      headers: headers,
    );
  }

  /// تنفيذ طلب POST
  Future<Map<String, dynamic>> post(
    ApiType type,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      type: type,
      endpoint: endpoint,
      method: 'POST',
      data: data,
      queryParams: queryParams,
      headers: headers,
    );
  }

  /// تنفيذ طلب PUT
  Future<Map<String, dynamic>> put(
    ApiType type,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      type: type,
      endpoint: endpoint,
      method: 'PUT',
      data: data,
      queryParams: queryParams,
      headers: headers,
    );
  }

  /// تنفيذ طلب DELETE
  Future<Map<String, dynamic>> delete(
    ApiType type,
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      type: type,
      endpoint: endpoint,
      method: 'DELETE',
      queryParams: queryParams,
      headers: headers,
    );
  }

  /// تنفيذ طلب HTTP
  Future<Map<String, dynamic>> _makeRequest({
    required ApiType type,
    required String endpoint,
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      // إضافة الهيدرات الافتراضية
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      };

      // بناء الرابط مع معلمات البحث
      final uri = Uri.parse('${_baseUrls[type]}$endpoint')
          .replace(queryParameters: queryParams);

      // تنفيذ الطلب
      http.Response response;
      final body = data != null ? jsonEncode(data) : null;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(
            uri,
            headers: requestHeaders,
          );
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: requestHeaders,
            body: body,
          );
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: requestHeaders,
            body: body,
          );
          break;
        case 'DELETE':
          response = await _client.delete(
            uri,
            headers: requestHeaders,
          );
          break;
        default:
          throw ServerException(
            message: 'طريقة HTTP غير مدعومة: $method',
            statusCode: 400,
          );
      }

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ServerException(
        message: 'لا يوجد اتصال بالإنترنت: ${e.message}',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      throw ServerException(
        message: 'تنسيق الاستجابة غير صالح: ${e.message}',
        statusCode: 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'حدث خطأ غير متوقع: $e',
        statusCode: 500,
      );
    }
  }

  /// معالجة استجابة الخادم
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    // تحويل النص إلى UTF-8 إذا كان موجودًا
    final responseBody = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes))
        : null;

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody as Map<String, dynamic>? ?? {};
    } else {
      throw ServerException(
        message: responseBody?['message']?.toString() ?? 'فشل في الطلب',
        statusCode: statusCode,
      );
    }
  }
}
