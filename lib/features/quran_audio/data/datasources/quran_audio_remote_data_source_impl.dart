import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:meshkat_elhoda/features/quran_audio/data/datasources/quran_audio_data_source.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/radio_station_model.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/reciter_model.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/surah_model.dart';

class QuranAudioRemoteDataSourceImpl implements QuranAudioRemoteDataSource {
  final http.Client client;

  // Language mapping for API
  static const Map<String, String> languageMap = {
    'ar': 'arabic',
    'en': 'english',
    'fr': 'french',
    'id': 'indonesian',
    'ur': 'urdu',
    'tr': 'turkish',
    'bn': 'bengali',
    'ms': 'malay',
    'fa': 'farsi',
    'es': 'spanish',
    'de': 'german',
    'zh': 'chinese',
  };

  QuranAudioRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ReciterModel>> getReciters(String language) async {
    try {
      final apiLanguage = languageMap[language] ?? 'english';
      final url = 'https://www.mp3quran.net/api/_${apiLanguage}.json';

      log('📡 Fetching reciters from: $url');

      final response = await client
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> recitersList = json['reciters'] ?? [];

        final reciters = recitersList
            .map(
              (reciter) =>
                  ReciterModel.fromJson(reciter as Map<String, dynamic>),
            )
            .toList();

        log('✅ Fetched ${reciters.length} reciters');
        return reciters;
      } else {
        // If the request fails and we're not already using English, try English
        if (apiLanguage != 'english') {
          log('⚠️ Failed for $apiLanguage, falling back to English');
          return await _getRecitersWithFallback();
        }
        throw Exception('Failed to load reciters: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error fetching reciters: $e');
      // Try English as fallback on any error
      if (!language.contains('en')) {
        try {
          log('🔄 Attempting English fallback...');
          return await _getRecitersWithFallback();
        } catch (fallbackError) {
          log('❌ English fallback also failed: $fallbackError');
        }
      }
      rethrow;
    }
  }

  /// Fallback method to fetch reciters in English
  Future<List<ReciterModel>> _getRecitersWithFallback() async {
    const fallbackUrl = 'https://www.mp3quran.net/api/_english.json';
    log('📡 Fetching reciters from fallback: $fallbackUrl');

    final response = await client
        .get(Uri.parse(fallbackUrl))
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Request timeout'),
        );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> recitersList = json['reciters'] ?? [];

      final reciters = recitersList
          .map(
            (reciter) => ReciterModel.fromJson(reciter as Map<String, dynamic>),
          )
          .toList();

      log('✅ Fetched ${reciters.length} reciters (English fallback)');
      return reciters;
    } else {
      throw Exception(
        'Failed to load reciters from fallback: ${response.statusCode}',
      );
    }
  }

  @override
  Future<List<SurahModel>> getSurahs() async {
    try {
      // Try multiple API endpoints
      const urls = [
        'https://api.alquran.cloud/v1/surah',
        'https://www.mp3quran.net/api/sura_json.php',
      ];

      for (var url in urls) {
        try {
          log('📡 Fetching surahs from: $url');

          final response = await client
              .get(Uri.parse(url))
              .timeout(
                const Duration(seconds: 15),
                onTimeout: () => throw Exception('Request timeout'),
              );

          if (response.statusCode == 200) {
            List<SurahModel> surahs = [];

            if (url.contains('alquran.cloud')) {
              // Handle alquran.cloud API format
              final Map<String, dynamic> json = jsonDecode(response.body);
              final List<dynamic> surahsList = json['data'] ?? [];

              surahs = surahsList
                  .map(
                    (surah) =>
                        SurahModel.fromJson(surah as Map<String, dynamic>),
                  )
                  .toList();
            } else {
              // Handle mp3quran.net API format
              final List<dynamic> surahsList = jsonDecode(response.body);

              surahs = surahsList
                  .map(
                    (surah) =>
                        SurahModel.fromJson(surah as Map<String, dynamic>),
                  )
                  .toList();
            }

            if (surahs.isNotEmpty) {
              log('✅ Fetched ${surahs.length} surahs from $url');
              return surahs;
            }
          }
        } catch (e) {
          log('⚠️ Failed to fetch from $url: $e');
          continue;
        }
      }

      // Fallback: Return hardcoded surahs if all APIs fail
      log('⚠️ Using fallback surahs data');
      return _getHardcodedSurahs();
    } catch (e) {
      log('❌ Error fetching surahs: $e');
      rethrow;
    }
  }

  // Hardcoded surahs data as fallback (all 114 surahs)
  List<SurahModel> _getHardcodedSurahs() {
    return [
      SurahModel(
        number: 1,
        name: 'الفاتحة',
        nameEnglish: 'Al-Fatiha',
        nameArabic: 'الفاتحة',
        ayahCount: 7,
        type: 'Meccan',
      ),
      SurahModel(
        number: 2,
        name: 'البقرة',
        nameEnglish: 'Al-Baqarah',
        nameArabic: 'البقرة',
        ayahCount: 286,
        type: 'Medinan',
      ),
      SurahModel(
        number: 3,
        name: 'آل عمران',
        nameEnglish: 'Ali Imran',
        nameArabic: 'آل عمران',
        ayahCount: 200,
        type: 'Medinan',
      ),
      SurahModel(
        number: 4,
        name: 'النساء',
        nameEnglish: 'An-Nisa',
        nameArabic: 'النساء',
        ayahCount: 176,
        type: 'Medinan',
      ),
      SurahModel(
        number: 5,
        name: 'المائدة',
        nameEnglish: 'Al-Maidah',
        nameArabic: 'المائدة',
        ayahCount: 120,
        type: 'Medinan',
      ),
      SurahModel(
        number: 6,
        name: 'الأنعام',
        nameEnglish: 'Al-An\'am',
        nameArabic: 'الأنعام',
        ayahCount: 165,
        type: 'Meccan',
      ),
      SurahModel(
        number: 7,
        name: 'الأعراف',
        nameEnglish: 'Al-A\'raf',
        nameArabic: 'الأعراف',
        ayahCount: 206,
        type: 'Meccan',
      ),
      SurahModel(
        number: 8,
        name: 'الأنفال',
        nameEnglish: 'Al-Anfal',
        nameArabic: 'الأنفال',
        ayahCount: 75,
        type: 'Medinan',
      ),
      SurahModel(
        number: 9,
        name: 'التوبة',
        nameEnglish: 'At-Tawbah',
        nameArabic: 'التوبة',
        ayahCount: 129,
        type: 'Medinan',
      ),
      SurahModel(
        number: 10,
        name: 'يونس',
        nameEnglish: 'Yunus',
        nameArabic: 'يونس',
        ayahCount: 109,
        type: 'Meccan',
      ),
      SurahModel(
        number: 11,
        name: 'هود',
        nameEnglish: 'Hud',
        nameArabic: 'هود',
        ayahCount: 123,
        type: 'Meccan',
      ),
      SurahModel(
        number: 12,
        name: 'يوسف',
        nameEnglish: 'Yusuf',
        nameArabic: 'يوسف',
        ayahCount: 111,
        type: 'Meccan',
      ),
      SurahModel(
        number: 13,
        name: 'الرعد',
        nameEnglish: 'Ar-Ra\'d',
        nameArabic: 'الرعد',
        ayahCount: 43,
        type: 'Medinan',
      ),
      SurahModel(
        number: 14,
        name: 'إبراهيم',
        nameEnglish: 'Ibrahim',
        nameArabic: 'إبراهيم',
        ayahCount: 52,
        type: 'Meccan',
      ),
      SurahModel(
        number: 15,
        name: 'الحجر',
        nameEnglish: 'Al-Hijr',
        nameArabic: 'الحجر',
        ayahCount: 99,
        type: 'Meccan',
      ),
      SurahModel(
        number: 16,
        name: 'النحل',
        nameEnglish: 'An-Nahl',
        nameArabic: 'النحل',
        ayahCount: 128,
        type: 'Medinan',
      ),
      SurahModel(
        number: 17,
        name: 'الإسراء',
        nameEnglish: 'Al-Isra',
        nameArabic: 'الإسراء',
        ayahCount: 111,
        type: 'Meccan',
      ),
      SurahModel(
        number: 18,
        name: 'الكهف',
        nameEnglish: 'Al-Kahf',
        nameArabic: 'الكهف',
        ayahCount: 110,
        type: 'Meccan',
      ),
      SurahModel(
        number: 19,
        name: 'مريم',
        nameEnglish: 'Maryam',
        nameArabic: 'مريم',
        ayahCount: 98,
        type: 'Meccan',
      ),
      SurahModel(
        number: 20,
        name: 'طه',
        nameEnglish: 'Ta-Ha',
        nameArabic: 'طه',
        ayahCount: 135,
        type: 'Meccan',
      ),
      SurahModel(
        number: 21,
        name: 'الأنبياء',
        nameEnglish: 'Al-Anbiya',
        nameArabic: 'الأنبياء',
        ayahCount: 112,
        type: 'Meccan',
      ),
      SurahModel(
        number: 22,
        name: 'الحج',
        nameEnglish: 'Al-Hajj',
        nameArabic: 'الحج',
        ayahCount: 78,
        type: 'Medinan',
      ),
      SurahModel(
        number: 23,
        name: 'المؤمنون',
        nameEnglish: 'Al-Mu\'minun',
        nameArabic: 'المؤمنون',
        ayahCount: 118,
        type: 'Meccan',
      ),
      SurahModel(
        number: 24,
        name: 'النور',
        nameEnglish: 'An-Nur',
        nameArabic: 'النور',
        ayahCount: 64,
        type: 'Medinan',
      ),
      SurahModel(
        number: 25,
        name: 'الفرقان',
        nameEnglish: 'Al-Furqan',
        nameArabic: 'الفرقان',
        ayahCount: 77,
        type: 'Meccan',
      ),
      SurahModel(
        number: 26,
        name: 'الشعراء',
        nameEnglish: 'Ash-Shu\'ara',
        nameArabic: 'الشعراء',
        ayahCount: 227,
        type: 'Meccan',
      ),
      SurahModel(
        number: 27,
        name: 'النمل',
        nameEnglish: 'An-Naml',
        nameArabic: 'النمل',
        ayahCount: 93,
        type: 'Meccan',
      ),
      SurahModel(
        number: 28,
        name: 'القصص',
        nameEnglish: 'Al-Qasas',
        nameArabic: 'القصص',
        ayahCount: 88,
        type: 'Meccan',
      ),
      SurahModel(
        number: 29,
        name: 'العنكبوت',
        nameEnglish: 'Al-Ankabut',
        nameArabic: 'العنكبوت',
        ayahCount: 69,
        type: 'Meccan',
      ),
      SurahModel(
        number: 30,
        name: 'الروم',
        nameEnglish: 'Ar-Rum',
        nameArabic: 'الروم',
        ayahCount: 60,
        type: 'Meccan',
      ),
      SurahModel(
        number: 31,
        name: 'لقمان',
        nameEnglish: 'Luqman',
        nameArabic: 'لقمان',
        ayahCount: 34,
        type: 'Meccan',
      ),
      SurahModel(
        number: 32,
        name: 'السجدة',
        nameEnglish: 'As-Sajdah',
        nameArabic: 'السجدة',
        ayahCount: 30,
        type: 'Meccan',
      ),
      SurahModel(
        number: 33,
        name: 'الأحزاب',
        nameEnglish: 'Al-Ahzab',
        nameArabic: 'الأحزاب',
        ayahCount: 73,
        type: 'Medinan',
      ),
      SurahModel(
        number: 34,
        name: 'سبأ',
        nameEnglish: 'Saba',
        nameArabic: 'سبأ',
        ayahCount: 54,
        type: 'Meccan',
      ),
      SurahModel(
        number: 35,
        name: 'فاطر',
        nameEnglish: 'Fatir',
        nameArabic: 'فاطر',
        ayahCount: 45,
        type: 'Meccan',
      ),
      SurahModel(
        number: 36,
        name: 'يس',
        nameEnglish: 'Ya-Sin',
        nameArabic: 'يس',
        ayahCount: 83,
        type: 'Meccan',
      ),
      SurahModel(
        number: 37,
        name: 'الصافات',
        nameEnglish: 'As-Saffat',
        nameArabic: 'الصافات',
        ayahCount: 182,
        type: 'Meccan',
      ),
      SurahModel(
        number: 38,
        name: 'ص',
        nameEnglish: 'Sad',
        nameArabic: 'ص',
        ayahCount: 88,
        type: 'Meccan',
      ),
      SurahModel(
        number: 39,
        name: 'الزمر',
        nameEnglish: 'Az-Zumar',
        nameArabic: 'الزمر',
        ayahCount: 75,
        type: 'Meccan',
      ),
      SurahModel(
        number: 40,
        name: 'غافر',
        nameEnglish: 'Ghafir',
        nameArabic: 'غافر',
        ayahCount: 85,
        type: 'Meccan',
      ),
      SurahModel(
        number: 41,
        name: 'فصلت',
        nameEnglish: 'Fussilat',
        nameArabic: 'فصلت',
        ayahCount: 54,
        type: 'Meccan',
      ),
      SurahModel(
        number: 42,
        name: 'الشورى',
        nameEnglish: 'Ash-Shura',
        nameArabic: 'الشورى',
        ayahCount: 53,
        type: 'Meccan',
      ),
      SurahModel(
        number: 43,
        name: 'الزخرف',
        nameEnglish: 'Az-Zukhruf',
        nameArabic: 'الزخرف',
        ayahCount: 89,
        type: 'Meccan',
      ),
      SurahModel(
        number: 44,
        name: 'الدخان',
        nameEnglish: 'Ad-Dukhan',
        nameArabic: 'الدخان',
        ayahCount: 59,
        type: 'Meccan',
      ),
      SurahModel(
        number: 45,
        name: 'الجاثية',
        nameEnglish: 'Al-Jathiyah',
        nameArabic: 'الجاثية',
        ayahCount: 37,
        type: 'Meccan',
      ),
      SurahModel(
        number: 46,
        name: 'الأحقاف',
        nameEnglish: 'Al-Ahqaf',
        nameArabic: 'الأحقاف',
        ayahCount: 35,
        type: 'Meccan',
      ),
      SurahModel(
        number: 47,
        name: 'محمد',
        nameEnglish: 'Muhammad',
        nameArabic: 'محمد',
        ayahCount: 38,
        type: 'Medinan',
      ),
      SurahModel(
        number: 48,
        name: 'الفتح',
        nameEnglish: 'Al-Fath',
        nameArabic: 'الفتح',
        ayahCount: 29,
        type: 'Medinan',
      ),
      SurahModel(
        number: 49,
        name: 'الحجرات',
        nameEnglish: 'Al-Hujurat',
        nameArabic: 'الحجرات',
        ayahCount: 18,
        type: 'Medinan',
      ),
      SurahModel(
        number: 50,
        name: 'ق',
        nameEnglish: 'Qaf',
        nameArabic: 'ق',
        ayahCount: 45,
        type: 'Meccan',
      ),
      SurahModel(
        number: 51,
        name: 'الذاريات',
        nameEnglish: 'Adh-Dhariyat',
        nameArabic: 'الذاريات',
        ayahCount: 60,
        type: 'Meccan',
      ),
      SurahModel(
        number: 52,
        name: 'الطور',
        nameEnglish: 'At-Tur',
        nameArabic: 'الطور',
        ayahCount: 49,
        type: 'Meccan',
      ),
      SurahModel(
        number: 53,
        name: 'النجم',
        nameEnglish: 'An-Najm',
        nameArabic: 'النجم',
        ayahCount: 62,
        type: 'Meccan',
      ),
      SurahModel(
        number: 54,
        name: 'القمر',
        nameEnglish: 'Al-Qamar',
        nameArabic: 'القمر',
        ayahCount: 55,
        type: 'Meccan',
      ),
      SurahModel(
        number: 55,
        name: 'الرحمن',
        nameEnglish: 'Ar-Rahman',
        nameArabic: 'الرحمن',
        ayahCount: 78,
        type: 'Medinan',
      ),
      SurahModel(
        number: 56,
        name: 'الواقعة',
        nameEnglish: 'Al-Waqiah',
        nameArabic: 'الواقعة',
        ayahCount: 96,
        type: 'Meccan',
      ),
      SurahModel(
        number: 57,
        name: 'الحديد',
        nameEnglish: 'Al-Hadid',
        nameArabic: 'الحديد',
        ayahCount: 29,
        type: 'Medinan',
      ),
      SurahModel(
        number: 58,
        name: 'المجادلة',
        nameEnglish: 'Al-Mujadilah',
        nameArabic: 'المجادلة',
        ayahCount: 22,
        type: 'Medinan',
      ),
      SurahModel(
        number: 59,
        name: 'الحشر',
        nameEnglish: 'Al-Hashr',
        nameArabic: 'الحشر',
        ayahCount: 24,
        type: 'Medinan',
      ),
      SurahModel(
        number: 60,
        name: 'الممتحنة',
        nameEnglish: 'Al-Mumtahanah',
        nameArabic: 'الممتحنة',
        ayahCount: 13,
        type: 'Medinan',
      ),
      SurahModel(
        number: 61,
        name: 'الصف',
        nameEnglish: 'As-Saff',
        nameArabic: 'الصف',
        ayahCount: 14,
        type: 'Medinan',
      ),
      SurahModel(
        number: 62,
        name: 'الجمعة',
        nameEnglish: 'Al-Jumu\'ah',
        nameArabic: 'الجمعة',
        ayahCount: 11,
        type: 'Medinan',
      ),
      SurahModel(
        number: 63,
        name: 'المنافقون',
        nameEnglish: 'Al-Munafiqun',
        nameArabic: 'المنافقون',
        ayahCount: 11,
        type: 'Medinan',
      ),
      SurahModel(
        number: 64,
        name: 'التغابن',
        nameEnglish: 'At-Taghabun',
        nameArabic: 'التغابن',
        ayahCount: 18,
        type: 'Medinan',
      ),
      SurahModel(
        number: 65,
        name: 'الطلاق',
        nameEnglish: 'At-Talaq',
        nameArabic: 'الطلاق',
        ayahCount: 12,
        type: 'Medinan',
      ),
      SurahModel(
        number: 66,
        name: 'التحريم',
        nameEnglish: 'At-Tahrim',
        nameArabic: 'التحريم',
        ayahCount: 12,
        type: 'Medinan',
      ),
      SurahModel(
        number: 67,
        name: 'الملك',
        nameEnglish: 'Al-Mulk',
        nameArabic: 'الملك',
        ayahCount: 30,
        type: 'Meccan',
      ),
      SurahModel(
        number: 68,
        name: 'القلم',
        nameEnglish: 'Al-Qalam',
        nameArabic: 'القلم',
        ayahCount: 52,
        type: 'Meccan',
      ),
      SurahModel(
        number: 69,
        name: 'الحاقة',
        nameEnglish: 'Al-Haqqah',
        nameArabic: 'الحاقة',
        ayahCount: 52,
        type: 'Meccan',
      ),
      SurahModel(
        number: 70,
        name: 'المعارج',
        nameEnglish: 'Al-Ma\'arij',
        nameArabic: 'المعارج',
        ayahCount: 44,
        type: 'Meccan',
      ),
      SurahModel(
        number: 71,
        name: 'نوح',
        nameEnglish: 'Nuh',
        nameArabic: 'نوح',
        ayahCount: 28,
        type: 'Meccan',
      ),
      SurahModel(
        number: 72,
        name: 'الجن',
        nameEnglish: 'Al-Jinn',
        nameArabic: 'الجن',
        ayahCount: 28,
        type: 'Meccan',
      ),
      SurahModel(
        number: 73,
        name: 'المزمل',
        nameEnglish: 'Al-Muzzammil',
        nameArabic: 'المزمل',
        ayahCount: 20,
        type: 'Meccan',
      ),
      SurahModel(
        number: 74,
        name: 'المدثر',
        nameEnglish: 'Al-Muddathir',
        nameArabic: 'المدثر',
        ayahCount: 56,
        type: 'Meccan',
      ),
      SurahModel(
        number: 75,
        name: 'القيامة',
        nameEnglish: 'Al-Qiyamah',
        nameArabic: 'القيامة',
        ayahCount: 40,
        type: 'Meccan',
      ),
      SurahModel(
        number: 76,
        name: 'الإنسان',
        nameEnglish: 'Al-Insan',
        nameArabic: 'الإنسان',
        ayahCount: 31,
        type: 'Medinan',
      ),
      SurahModel(
        number: 77,
        name: 'المرسلات',
        nameEnglish: 'Al-Mursalat',
        nameArabic: 'المرسلات',
        ayahCount: 50,
        type: 'Meccan',
      ),
      SurahModel(
        number: 78,
        name: 'النبأ',
        nameEnglish: 'An-Naba',
        nameArabic: 'النبأ',
        ayahCount: 40,
        type: 'Meccan',
      ),
      SurahModel(
        number: 79,
        name: 'الناشعات',
        nameEnglish: 'An-Nazi\'at',
        nameArabic: 'الناشعات',
        ayahCount: 46,
        type: 'Meccan',
      ),
      SurahModel(
        number: 80,
        name: 'عبس',
        nameEnglish: 'Abasa',
        nameArabic: 'عبس',
        ayahCount: 42,
        type: 'Meccan',
      ),
      SurahModel(
        number: 81,
        name: 'التكوير',
        nameEnglish: 'At-Takwir',
        nameArabic: 'التكوير',
        ayahCount: 29,
        type: 'Meccan',
      ),
      SurahModel(
        number: 82,
        name: 'الإنفطار',
        nameEnglish: 'Al-Infitar',
        nameArabic: 'الإنفطار',
        ayahCount: 19,
        type: 'Meccan',
      ),
      SurahModel(
        number: 83,
        name: 'المطففين',
        nameEnglish: 'Al-Mutaffifin',
        nameArabic: 'المطففين',
        ayahCount: 36,
        type: 'Meccan',
      ),
      SurahModel(
        number: 84,
        name: 'الانشقاق',
        nameEnglish: 'Al-Inshiqaq',
        nameArabic: 'الانشقاق',
        ayahCount: 25,
        type: 'Meccan',
      ),
      SurahModel(
        number: 85,
        name: 'البروج',
        nameEnglish: 'Al-Buruj',
        nameArabic: 'البروج',
        ayahCount: 22,
        type: 'Meccan',
      ),
      SurahModel(
        number: 86,
        name: 'الطارق',
        nameEnglish: 'At-Tariq',
        nameArabic: 'الطارق',
        ayahCount: 17,
        type: 'Meccan',
      ),
      SurahModel(
        number: 87,
        name: 'الأعلى',
        nameEnglish: 'Al-A\'la',
        nameArabic: 'الأعلى',
        ayahCount: 19,
        type: 'Meccan',
      ),
      SurahModel(
        number: 88,
        name: 'الغاشية',
        nameEnglish: 'Al-Ghashiyah',
        nameArabic: 'الغاشية',
        ayahCount: 26,
        type: 'Meccan',
      ),
      SurahModel(
        number: 89,
        name: 'الفجر',
        nameEnglish: 'Al-Fajr',
        nameArabic: 'الفجر',
        ayahCount: 30,
        type: 'Meccan',
      ),
      SurahModel(
        number: 90,
        name: 'البلد',
        nameEnglish: 'Al-Balad',
        nameArabic: 'البلد',
        ayahCount: 20,
        type: 'Meccan',
      ),
      SurahModel(
        number: 91,
        name: 'الشمس',
        nameEnglish: 'Ash-Shams',
        nameArabic: 'الشمس',
        ayahCount: 15,
        type: 'Meccan',
      ),
      SurahModel(
        number: 92,
        name: 'الليل',
        nameEnglish: 'Al-Layl',
        nameArabic: 'الليل',
        ayahCount: 21,
        type: 'Meccan',
      ),
      SurahModel(
        number: 93,
        name: 'الضحى',
        nameEnglish: 'Ad-Duha',
        nameArabic: 'الضحى',
        ayahCount: 11,
        type: 'Meccan',
      ),
      SurahModel(
        number: 94,
        name: 'الشرح',
        nameEnglish: 'Ash-Sharh',
        nameArabic: 'الشرح',
        ayahCount: 8,
        type: 'Meccan',
      ),
      SurahModel(
        number: 95,
        name: 'التين',
        nameEnglish: 'At-Tin',
        nameArabic: 'التين',
        ayahCount: 8,
        type: 'Meccan',
      ),
      SurahModel(
        number: 96,
        name: 'العلق',
        nameEnglish: 'Al-Alaq',
        nameArabic: 'العلق',
        ayahCount: 19,
        type: 'Meccan',
      ),
      SurahModel(
        number: 97,
        name: 'القدر',
        nameEnglish: 'Al-Qadr',
        nameArabic: 'القدر',
        ayahCount: 5,
        type: 'Meccan',
      ),
      SurahModel(
        number: 98,
        name: 'البينة',
        nameEnglish: 'Al-Bayyinah',
        nameArabic: 'البينة',
        ayahCount: 8,
        type: 'Medinan',
      ),
      SurahModel(
        number: 99,
        name: 'الزلزلة',
        nameEnglish: 'Az-Zalzalah',
        nameArabic: 'الزلزلة',
        ayahCount: 8,
        type: 'Medinan',
      ),
      SurahModel(
        number: 100,
        name: 'العاديات',
        nameEnglish: 'Al-Adiyat',
        nameArabic: 'العاديات',
        ayahCount: 11,
        type: 'Meccan',
      ),
      SurahModel(
        number: 101,
        name: 'القارعة',
        nameEnglish: 'Al-Qari\'ah',
        nameArabic: 'القارعة',
        ayahCount: 11,
        type: 'Meccan',
      ),
      SurahModel(
        number: 102,
        name: 'التكاثر',
        nameEnglish: 'At-Takathur',
        nameArabic: 'التكاثر',
        ayahCount: 8,
        type: 'Meccan',
      ),
      SurahModel(
        number: 103,
        name: 'العصر',
        nameEnglish: 'Al-Asr',
        nameArabic: 'العصر',
        ayahCount: 3,
        type: 'Meccan',
      ),
      SurahModel(
        number: 104,
        name: 'الهمزة',
        nameEnglish: 'Al-Humazah',
        nameArabic: 'الهمزة',
        ayahCount: 9,
        type: 'Meccan',
      ),
      SurahModel(
        number: 105,
        name: 'الفيل',
        nameEnglish: 'Al-Fil',
        nameArabic: 'الفيل',
        ayahCount: 5,
        type: 'Meccan',
      ),
      SurahModel(
        number: 106,
        name: 'قريش',
        nameEnglish: 'Quraysh',
        nameArabic: 'قريش',
        ayahCount: 4,
        type: 'Meccan',
      ),
      SurahModel(
        number: 107,
        name: 'الماعون',
        nameEnglish: 'Al-Ma\'un',
        nameArabic: 'الماعون',
        ayahCount: 7,
        type: 'Meccan',
      ),
      SurahModel(
        number: 108,
        name: 'الكوثر',
        nameEnglish: 'Al-Kawthar',
        nameArabic: 'الكوثر',
        ayahCount: 3,
        type: 'Meccan',
      ),
      SurahModel(
        number: 109,
        name: 'الكافرون',
        nameEnglish: 'Al-Kafirun',
        nameArabic: 'الكافرون',
        ayahCount: 6,
        type: 'Meccan',
      ),
      SurahModel(
        number: 110,
        name: 'النصر',
        nameEnglish: 'An-Nasr',
        nameArabic: 'النصر',
        ayahCount: 3,
        type: 'Medinan',
      ),
      SurahModel(
        number: 111,
        name: 'المسد',
        nameEnglish: 'Al-Masad',
        nameArabic: 'المسد',
        ayahCount: 5,
        type: 'Meccan',
      ),
      SurahModel(
        number: 112,
        name: 'الإخلاص',
        nameEnglish: 'Al-Ikhlas',
        nameArabic: 'الإخلاص',
        ayahCount: 4,
        type: 'Meccan',
      ),
      SurahModel(
        number: 113,
        name: 'الفلق',
        nameEnglish: 'Al-Falaq',
        nameArabic: 'الفلق',
        ayahCount: 5,
        type: 'Meccan',
      ),
      SurahModel(
        number: 114,
        name: 'الناس',
        nameEnglish: 'An-Nas',
        nameArabic: 'الناس',
        ayahCount: 6,
        type: 'Meccan',
      ),
    ];
  }

  @override
  Future<List<RadioStationModel>> getRadioStations() async {
    try {
      // ✅ Fixed: Use specific language file instead of directory
      // The API endpoint returns HTML directory listing if we just use the folder
      const baseUrl = 'https://www.mp3quran.net/api/radio-v2/radio_ar.json';

      log('📡 Fetching radio stations from: $baseUrl');

      final response = await client
          .get(Uri.parse(baseUrl))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        // The API returns { "radios": [...] }
        final List<dynamic> stationsList = json['radios'] ?? [];

        final stations = stationsList
            .map(
              (station) =>
                  RadioStationModel.fromJson(station as Map<String, dynamic>),
            )
            .toList();

        log('✅ Fetched ${stations.length} radio stations');
        return stations;
      } else {
        throw Exception(
          'Failed to load radio stations: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error fetching radio stations: $e');
      rethrow;
    }
  }
}
