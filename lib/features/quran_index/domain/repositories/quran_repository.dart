import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/ayah_entity.dart';
import '../entities/juz_entity.dart';
import '../entities/reciter_entity.dart';
import '../entities/surah_entity.dart';
import '../entities/tafsir_entity.dart';
import '../entities/quran_edition_entity.dart';

abstract class QuranRepository {
  Future<Either<Failure, List<SurahEntity>>> getAllSurahs();
  Future<Either<Failure, List<AyahEntity>>> getSurahByNumber(
    int number, {
    String? reciterId,
    String? language,
  });
  Future<Either<Failure, JuzEntity>> getJuzSurahs(int number);
  Future<Either<Failure, TafsirEntity>> getAyahTafsir(
    int surahNumber,
    int ayahNumber, {
    String? tafsirId,
  });
  Future<Either<Failure, List<ReciterEntity>>> getReciters();
  Future<Either<Failure, String>> getAudioUrl(
    int surahNumber,
    String reciterId,
  );
  Future<Either<Failure, void>> saveLastPosition(
    int surahNumber,
    int ayahNumber,
  );
  Future<Either<Failure, ({int surahNumber, int ayahNumber})>>
  getLastPosition();

  Future<Either<Failure, List<QuranEditionEntity>>> getAvailableTafsirs(
    String language,
  );
  Future<Either<Failure, List<QuranEditionEntity>>> getAvailableReciters(
    String language,
  );
}
