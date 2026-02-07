import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/ayah_entity.dart';
import '../repositories/quran_repository.dart';

class GetSurahByNumber {
  final QuranRepository repository;

  GetSurahByNumber(this.repository);

  Future<Either<Failure, List<AyahEntity>>> call(
    int number, {
    String? reciterId,
    String? language,
  }) {
    return repository.getSurahByNumber(
      number,
      reciterId: reciterId,
      language: language,
    );
  }
}
