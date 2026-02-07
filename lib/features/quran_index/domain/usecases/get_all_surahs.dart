import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/surah_entity.dart';
import '../repositories/quran_repository.dart';

class GetAllSurahs {
  final QuranRepository repository;

  GetAllSurahs(this.repository);

  Future<Either<Failure, List<SurahEntity>>> call() {
    return repository.getAllSurahs();
  }
}
