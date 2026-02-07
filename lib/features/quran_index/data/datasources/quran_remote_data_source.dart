import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:meshkat_elhoda/core/network/firebase_service.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';
import '../models/juz_model.dart';
import '../models/reciter_model.dart';
import '../models/tafsir_model.dart';
import '../models/quran_edition_model.dart';

abstract class QuranRemoteDataSource {
  Future<List<SurahModel>> getAllSurahs();
  Future<List<AyahModel>> getSurahByNumber(int number, {String? reciterId});
  Future<JuzModel> getJuzSurahs(int number);
  Future<TafsirModel> getAyahTafsir(
    int surahNumber,
    int ayahNumber, {
    String? tafsirId,
  });
  Future<List<ReciterModel>> getReciters();
  Future<String> getAudioUrl(int surahNumber, String reciterId);
  Future<List<QuranEditionModel>> getAvailableTafsirs(String language);
  Future<List<QuranEditionModel>> getAvailableReciters(String language);
}

const Map<String, String> translations = {
  'ar': 'quran-uthmani', // الرسم العثماني - مجمع الملك فهد
  'en': 'en.hilali', // The Noble Quran - Hilali & Khan (King Fahd Complex)
  'fr': 'fr.hamidullah', // Hamidullah (Widely used/printed by KSA)
  'id': 'id.indonesian', // Ministry of Religious Affairs (Standard)
  'ur': 'ur.junagarhi', // Maulana Muhammad Junagarhi (Common KSA print)
  'tr': 'tr.diyanet', // Diyanet Isleri (Turkish Authority)
  'bn': 'bn.bengali', // Muhiuddin Khan
  'ms': 'ms.basmeih', // Abdullah Muhammad Basmeih (Std Malaysia)
  'fa': 'fa.makarem', // Makarem Shirazi
  'es': 'es.cortes', // Julio Cortes
  'de': 'de.bubenheim', // Bubenheim & Elyas (King Fahd Complex used)
  'zh': 'zh.majian', // Ma Jian (King Fahd Complex used)
};

const Map<String, String> defaultTafsirs = {
  'ar': 'ar.muyassar', // التفسير الميسر
  'en': 'en.asad', // تفسير أسد
  'fr': 'fr.hamidullah', // تفسير حميد الله
  'id': 'id.indonesian', // التفسير الإندونيسي
  'ur': 'ur.ahmedali', // تفسير أحمد علي
  'tr': 'tr.yazir', // تفسير يازير
  'bn': 'bn.bengali', // التفسير البنغالي
  'ms': 'ms.malay', // التفسير الماليزي
  'fa': 'fa.makarem', // تفسير مكارم الشيرازي
  'es': 'es.cortes', // تفسير كورتيس
  'de': 'de.bubenheim', // تفسير بوبنهايم
  'zh': 'zh.majian', // التفسير الصيني
};

const Map<String, String> defaultReciters = {
  'ar': 'ar.alafasy', // مشاري العفاسي - عربي
  'en': 'en.walk', // إبراهيم ووك - إنجليزي
  'fr': 'fr.leclerc', // يوسف ليكليرك - فرنسي
  'ur': 'ur.khan', // شمشاد علي خان - أردي
  'fa': 'fa.hedayatfarfooladvand', // فولادفاند - فارسي
  'zh': 'zh.chinese', // قارئ صيني
  'ru': 'ru.kuliev-audio', // إلمير كولييف - روسي
  'id': 'ar.alafasy',
  'tr': 'ar.alafasy',
  'bn': 'ar.alafasy',
  'ms': 'ar.alafasy',
  'es': 'ar.alafasy',
  'de': 'ar.alafasy',
};

class QuranRemoteDataSourceImpl implements QuranRemoteDataSource {
  final http.Client client;
  final FirebaseService _firebaseService;
  final String baseUrl = 'https://api.alquran.cloud/v1';

  QuranRemoteDataSourceImpl({
    required this.client,
    required FirebaseService firebaseService,
  }) : _firebaseService = firebaseService;

  @override
  Future<List<SurahModel>> getAllSurahs() async {
    final user = _firebaseService.currentUser;
    final userData = await _firebaseService.getDocument('users', user!.uid);
    final preferredLanguage = userData['language'] ?? 'ar';

    // نحصل على السور باللغة المفضلة للمستخدم
    final response = await client.get(
      Uri.parse('$baseUrl/quran/${translations[preferredLanguage]}'),
    );

    log(response.request!.url.toString());

    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      final List<dynamic> surahs = decodedJson['data']['surahs'];

      return surahs.map((surah) {
        final Map<String, dynamic> surahMap = Map<String, dynamic>.from(surah);
        final List<dynamic> ayahsList = surahMap['ayahs'];

        // معالجة الآيات وتحويل sajda إلى boolean
        final List<Map<String, dynamic>> processedAyahs = ayahsList.map((ayah) {
          final Map<String, dynamic> ayahMap = Map<String, dynamic>.from(ayah);
          return {
            ...ayahMap,
            'sajda': ayahMap['sajda'] is Map
                ? (ayahMap['sajda'] as Map).isNotEmpty
                : false,
          };
        }).toList();

        surahMap['ayahs'] = processedAyahs;

        final SurahModel surahModel = SurahModel.fromJson(surahMap);
        return surahModel;
      }).toList();
    } else {
      throw Exception('Failed to load surahs');
    }
  }

  @override
  Future<List<AyahModel>> getSurahByNumber(
    int number, {
    String? reciterId,
  }) async {
    final user = _firebaseService.currentUser;
    final userData = await _firebaseService.getDocument('users', user!.uid);
    final preferredLanguage = userData['language'] ?? 'ar';

    // ✅ القارئ الصوتي
    final audioReciter =
        reciterId ?? defaultReciters[preferredLanguage] ?? 'ar.alafasy';

    // ✅ الترجمة بناءً على لغة المستخدم (لغير العربية)
    final translationEdition = translations[preferredLanguage];
    final needsTranslation =
        preferredLanguage != 'ar' && translationEdition != null;

    log(
      '📖 Fetching surah $number - Audio: $audioReciter, Translation: ${needsTranslation ? translationEdition : "Not needed (Arabic)"}',
    );

    // ✅ جلب الصوت
    final audioResponse = await client.get(
      Uri.parse('$baseUrl/surah/$number/$audioReciter'),
    );

    if (audioResponse.statusCode != 200) {
      throw Exception('Failed to load surah with audio');
    }

    final audioJson = json.decode(audioResponse.body);
    final List<dynamic> audioAyahs = audioJson['data']['ayahs'];

    // ✅ جلب الترجمة إذا كانت اللغة غير عربية
    Map<int, String> translationsMap = {};

    if (needsTranslation) {
      try {
        final translationResponse = await client.get(
          Uri.parse('$baseUrl/surah/$number/$translationEdition'),
        );

        if (translationResponse.statusCode == 200) {
          final translationJson = json.decode(translationResponse.body);
          final List<dynamic> translationAyahs =
              translationJson['data']['ayahs'];

          // إنشاء خريطة الترجمات بناءً على رقم الآية في السورة
          for (final ayah in translationAyahs) {
            final numberInSurah = ayah['numberInSurah'] as int;
            final text = ayah['text'] as String;
            translationsMap[numberInSurah] = text;
          }

          log(
            '✅ Loaded ${translationsMap.length} translations for surah $number',
          );
        } else {
          log(
            '⚠️ Failed to load translations: ${translationResponse.statusCode}',
          );
        }
      } catch (e) {
        log('⚠️ Error loading translations: $e');
        // نستمر بدون ترجمة في حالة الخطأ
      }
    }

    // ✅ دمج الصوت مع الترجمة
    return audioAyahs.map((ayah) {
      final numberInSurah = ayah['numberInSurah'] as int;
      final translation = translationsMap[numberInSurah];

      return AyahModel.fromJson(
        ayah,
        surahNumber: number,
        translationText: translation,
      );
    }).toList();
  }

  @override
  Future<JuzModel> getJuzSurahs(int number) async {
    final response = await client.get(Uri.parse('$baseUrl/juz/$number'));
    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      return JuzModel.fromJson(decodedJson['data']);
    } else {
      throw Exception('Failed to load juz');
    }
  }

  @override
  Future<TafsirModel> getAyahTafsir(
    int surahNumber,
    int ayahNumber, {
    String? tafsirId,
  }) async {
    final user = _firebaseService.currentUser;
    final userData = await _firebaseService.getDocument('users', user!.uid);
    final language = userData['language'] ?? 'ar';

    // استخدم الـ tafsirs map بدلاً من translations
    final tafsirIdentifier =
        tafsirId ?? defaultTafsirs[language] ?? 'ar.muyassar';

    final response = await client.get(
      Uri.parse('$baseUrl/ayah/$surahNumber:$ayahNumber/$tafsirIdentifier'),
    );
    log("tafsir url: ${response.request!.url}");
    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      log("tafsir data: ${decodedJson['data']}");
      return TafsirModel.fromJson(decodedJson['data']);
    } else {
      throw Exception('Failed to load tafsir');
    }
  }

  @override
  Future<List<ReciterModel>> getReciters() async {
    final response = await client.get(
      Uri.parse('$baseUrl/edition/format/audio'),
    );
    log("reciters url: ${response.request!.url}");
    log("reciters data: ${response.body}");
    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      final List<dynamic> reciters = decodedJson['data'];
      return reciters.map((reciter) => ReciterModel.fromJson(reciter)).toList();
    } else {
      throw Exception('Failed to load reciters');
    }
  }

  @override
  Future<String> getAudioUrl(int surahNumber, String reciterId) async {
    log("Getting audio URL for Surah $surahNumber and Reciter $reciterId");
    return '$baseUrl/surah/$surahNumber/$reciterId';
  }

  @override
  Future<List<QuranEditionModel>> getAvailableTafsirs(String language) async {
    try {
      // Correct API format: /edition/language/{lang}?format=text
      final url = '$baseUrl/edition/language/$language?format=text';
      log('📖 Fetching tafsirs from: $url');

      final response = await client.get(Uri.parse(url));

      log('📖 Tafsirs response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        final List<dynamic> data = decodedJson['data'];

        // Filter to get tafsir OR translation (translations work as tafsir for non-Arabic)
        // Exclude transliteration
        final tafsirs = data.where((e) {
          final type = e['type'] as String;
          return type == 'tafsir' || type == 'translation';
        }).toList();

        log(
          '📖 Found ${tafsirs.length} tafsirs/translations for language: $language',
        );
        return tafsirs.map((e) => QuranEditionModel.fromJson(e)).toList();
      } else {
        log(
          '❌ Failed to load tafsirs: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to load available tafsirs: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error in getAvailableTafsirs: $e');
      rethrow;
    }
  }

  @override
  Future<List<QuranEditionModel>> getAvailableReciters(String language) async {
    try {
      // Correct API format: /edition/language/{lang}?format=audio
      final url = '$baseUrl/edition/language/$language?format=audio';
      log('🎙️ Fetching reciters from: $url');

      final response = await client.get(Uri.parse(url));

      log('🎙️ Reciters response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        final List<dynamic> data = decodedJson['data'];

        // Filter to get only versebyverse type reciters
        final reciters = data
            .where((e) => e['type'] == 'versebyverse')
            .toList();

        log('🎙️ Found ${reciters.length} reciters for language: $language');
        return reciters.map((e) => QuranEditionModel.fromJson(e)).toList();
      } else {
        log(
          '❌ Failed to load reciters: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to load available reciters: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error in getAvailableReciters: $e');
      rethrow;
    }
  }
}
