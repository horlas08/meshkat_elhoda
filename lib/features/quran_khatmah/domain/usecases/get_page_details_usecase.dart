import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/repositories/quran_repository.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/entities/ayah_entity.dart';
import 'package:meshkat_elhoda/features/quran_index/data/models/surah_model.dart';
import '../entities/page_details_entity.dart';

class GetPageDetailsUseCase {
  final QuranRepository quranRepository;

  GetPageDetailsUseCase(this.quranRepository);

  Future<Either<Failure, PageDetailsEntity>> call(int pageNumber) async {
    // 1. Get all surahs
    final result = await quranRepository.getAllSurahs();

    return result.fold((failure) => Left(failure), (surahs) {
      // 2. Filter ayahs for the given page
      final List<AyahEntity> pageAyahs = [];

      // Iterate through surahs to find ayahs on this page
      for (final surah in surahs) {
        if (surah is SurahModel) {
          final ayahsOnPage = surah.ayahs
              .where((a) => a.page == pageNumber)
              .toList();
          if (ayahsOnPage.isNotEmpty) {
            pageAyahs.addAll(ayahsOnPage);
          }
        }
      }

      if (pageAyahs.isEmpty) {
        return Left(CacheFailure(message: 'Page $pageNumber not found'));
      }

      // Sort by ayah number
      pageAyahs.sort((a, b) => a.number.compareTo(b.number));

      final lastAyah = pageAyahs.last;

      final surahOfLastAyah = surahs.firstWhere((s) {
        if (s is SurahModel) {
          return s.ayahs.contains(lastAyah);
        }
        return false;
      }, orElse: () => surahs.first as SurahModel);

      return Right(
        PageDetailsEntity(
          pageNumber: pageNumber,
          surahName: surahOfLastAyah.name,
          surahNameEnglish: surahOfLastAyah.englishName,
          juz: lastAyah.juz,
          hizb: (lastAyah.hizbQuarter / 4).ceil(),
          manzil: lastAyah.manzil,
          ruku: lastAyah.ruku,
          totalAyahsInSurah: surahOfLastAyah.numberOfAyahs,
          ayahs: pageAyahs,
        ),
      );
    });
  }
}
