import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../repositories/quran_repository.dart';

class GetLastPosition {
  final QuranRepository repository;

  GetLastPosition(this.repository);

  Future<Either<Failure, ({int surahNumber, int ayahNumber})>> call() {
    return repository.getLastPosition();
  }
}
