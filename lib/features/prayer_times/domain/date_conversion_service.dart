import 'dart:convert';

import 'package:http/http.dart' as http;

class DateConversionResult {
  final String inputCalendar; // 'gregorian' or 'hijri'
  final String inputDate;
  final String outputCalendar;
  final String outputDate;

  const DateConversionResult({
    required this.inputCalendar,
    required this.inputDate,
    required this.outputCalendar,
    required this.outputDate,
  });
}

/// خدمة بسيطة لتحويل التاريخ بين الميلادي والهجري باستخدام API عام (AlAdhan).
///
/// ملاحظة: الخدمة للاستخدام التقريبي فقط، وقد تختلف النتائج بين التقويمات المختلفة.
class DateConversionService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  /// تحويل من ميلادي إلى هجري.
  /// [gregorianDate] بالصيغة dd-MM-yyyy
  Future<DateConversionResult> convertGregorianToHijri(
    String gregorianDate,
  ) async {
    final uri = Uri.parse('$_baseUrl/gToH?date=$gregorianDate');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('فشل الاتصال بخدمة تحويل التاريخ');
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    if (jsonBody['code'] != 200) {
      throw Exception(jsonBody['data']?.toString() ?? 'خطأ في تحويل التاريخ');
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    final hijri = data['hijri'] as Map<String, dynamic>;
    final hijriDate = hijri['date'] as String; // مثل 23-05-1446

    return DateConversionResult(
      inputCalendar: 'gregorian',
      inputDate: gregorianDate,
      outputCalendar: 'hijri',
      outputDate: hijriDate,
    );
  }

  /// تحويل من هجري إلى ميلادي.
  /// [hijriDate] بالصيغة dd-MM-yyyy
  Future<DateConversionResult> convertHijriToGregorian(String hijriDate) async {
    final uri = Uri.parse('$_baseUrl/hToG?date=$hijriDate');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('فشل الاتصال بخدمة تحويل التاريخ');
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    if (jsonBody['code'] != 200) {
      throw Exception(jsonBody['data']?.toString() ?? 'خطأ في تحويل التاريخ');
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    final gregorian = data['gregorian'] as Map<String, dynamic>;
    final gregorianDate = gregorian['date'] as String; // مثل 05-01-2025

    return DateConversionResult(
      inputCalendar: 'hijri',
      inputDate: hijriDate,
      outputCalendar: 'gregorian',
      outputDate: gregorianDate,
    );
  }
}
