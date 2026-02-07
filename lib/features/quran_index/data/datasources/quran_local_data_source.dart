import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';

abstract class QuranLocalDataSource {
  Future<void> saveLastPosition(int surahNumber, int ayahNumber);
  Future<({int surahNumber, int ayahNumber})?> getLastPosition();
  Future<void> cacheAudioFile(
    String reciterId,
    int surahNumber,
    String filePath,
  );
  Future<String?> getCachedAudioFile(String reciterId, int surahNumber);

  // ✅ New methods for caching Quran data
  Future<void> cacheSurahs(List<SurahModel> surahs, {String? language});
  Future<List<SurahModel>?> getCachedSurahs({String? language});

  // ✅ New methods for caching Surah details
  Future<void> cacheSurahDetails(
    int surahNumber,
    List<AyahModel> ayahs, {
    String? reciterId,
    String? language,
  });
  Future<List<AyahModel>?> getCachedSurahDetails(
    int surahNumber, {
    String? reciterId,
    String? language,
  });
}

class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const lastPositionKey = 'LAST_POSITION';
  static const audioFilesKey = 'AUDIO_FILES';

  QuranLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveLastPosition(int surahNumber, int ayahNumber) async {
    final position = {'surahNumber': surahNumber, 'ayahNumber': ayahNumber};
    await sharedPreferences.setString(lastPositionKey, json.encode(position));
  }

  @override
  Future<({int surahNumber, int ayahNumber})?> getLastPosition() async {
    final jsonString = sharedPreferences.getString(lastPositionKey);
    if (jsonString != null) {
      final decoded = json.decode(jsonString);
      return (
        surahNumber: decoded['surahNumber'] as int,
        ayahNumber: decoded['ayahNumber'] as int,
      );
    }
    return null;
  }

  @override
  Future<void> cacheAudioFile(
    String reciterId,
    int surahNumber,
    String filePath,
  ) async {
    final audioFiles = sharedPreferences.getStringList(audioFilesKey) ?? [];
    final audioFile = json.encode({
      'reciterId': reciterId,
      'surahNumber': surahNumber,
      'filePath': filePath,
    });
    audioFiles.add(audioFile);
    await sharedPreferences.setStringList(audioFilesKey, audioFiles);
  }

  @override
  Future<String?> getCachedAudioFile(String reciterId, int surahNumber) async {
    final audioFiles = sharedPreferences.getStringList(audioFilesKey) ?? [];
    final audioFile = audioFiles
        .map((e) => json.decode(e))
        .firstWhere(
          (file) =>
              file['reciterId'] == reciterId &&
              file['surahNumber'] == surahNumber,
          orElse: () => null,
        );
    return audioFile?['filePath'] as String?;
  }

  // ✅ Cache Surahs implementation
  // 🔄 تم تعديل المفتاح ليشمل اللغة لضمان تحميل البيانات الصحيحة عند تغيير اللغة
  String _getSurahsCacheKey({String? language}) =>
      'CACHED_SURAHS_${language ?? 'ar'}';

  @override
  Future<void> cacheSurahs(List<SurahModel> surahs, {String? language}) async {
    final jsonList = surahs.map((s) => s.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(
      _getSurahsCacheKey(language: language),
      jsonString,
    );
  }

  @override
  Future<List<SurahModel>?> getCachedSurahs({String? language}) async {
    final jsonString = sharedPreferences.getString(
      _getSurahsCacheKey(language: language),
    );
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => SurahModel.fromJson(json)).toList();
    }
    return null;
  }

  // ✅ Cache Surah Details implementation
  // 🔄 تم تعديل المفتاح ليشمل القارئ واللغة لضمان تحميل الصوت والترجمة الصحيحة
  String _getSurahDetailsKey(
    int surahNumber, {
    String? reciterId,
    String? language,
  }) =>
      'CACHED_SURAH_DETAILS_${surahNumber}_${reciterId ?? 'default'}_${language ?? 'ar'}';

  @override
  Future<void> cacheSurahDetails(
    int surahNumber,
    List<AyahModel> ayahs, {
    String? reciterId,
    String? language,
  }) async {
    final jsonList = ayahs.map((a) => a.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(
      _getSurahDetailsKey(
        surahNumber,
        reciterId: reciterId,
        language: language,
      ),
      jsonString,
    );
  }

  @override
  Future<List<AyahModel>?> getCachedSurahDetails(
    int surahNumber, {
    String? reciterId,
    String? language,
  }) async {
    final jsonString = sharedPreferences.getString(
      _getSurahDetailsKey(
        surahNumber,
        reciterId: reciterId,
        language: language,
      ),
    );
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => AyahModel.fromJson(json)).toList();
    }
    return null;
  }
}
