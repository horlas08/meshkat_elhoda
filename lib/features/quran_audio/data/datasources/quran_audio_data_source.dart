import 'package:meshkat_elhoda/features/quran_audio/data/models/radio_station_model.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/reciter_model.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/surah_model.dart';

abstract class QuranAudioRemoteDataSource {
  Future<List<ReciterModel>> getReciters(String language);
  Future<List<SurahModel>> getSurahs();
  Future<List<RadioStationModel>> getRadioStations();
}

abstract class QuranAudioLocalDataSource {
  Future<List<ReciterModel>> getCachedReciters(String language);
  Future<void> cacheReciters(List<ReciterModel> reciters, String language);

  Future<List<SurahModel>> getCachedSurahs();
  Future<void> cacheSurahs(List<SurahModel> surahs);

  Future<List<RadioStationModel>> getCachedRadioStations();
  Future<void> cacheRadioStations(List<RadioStationModel> stations);

  Future<void> saveFavoriteReciter(ReciterModel reciter);
  Future<List<ReciterModel>> getFavoriteReciters();
  Future<void> removeFavoriteReciter(String reciterId);

  Future<void> saveLastPlayedTrack(
    String surahNumber,
    String surahName,
    String reciterName,
    String audioUrl,
    int positionMillis,
  );
  Future<Map<String, dynamic>?> getLastPlayedTrack();

  Future<void> addToRecentlyPlayed(
    String surahNumber,
    String surahName,
    String reciterName,
    String audioUrl,
  );
  Future<List<Map<String, dynamic>>> getRecentlyPlayedTracks();
}
