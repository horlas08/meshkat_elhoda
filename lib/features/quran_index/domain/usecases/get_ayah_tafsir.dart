import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/tafsir_entity.dart';
import '../repositories/quran_repository.dart';

class GetAyahTafsir {
  final QuranRepository repository;

  GetAyahTafsir(this.repository);

  Future<Either<Failure, TafsirEntity>> call(
    int surahNumber,
    int ayahNumber, {
    String? tafsirId,
  }) {
    return repository.getAyahTafsir(
      surahNumber,
      ayahNumber,
      tafsirId: tafsirId,
    );
  }
}
