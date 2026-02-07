import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/juz_entity.dart';
import '../repositories/quran_repository.dart';

class GetJuzSurahs {
  final QuranRepository repository;

  GetJuzSurahs(this.repository);

  Future<Either<Failure, JuzEntity>> call(int number) {
    return repository.getJuzSurahs(number);
  }
}
