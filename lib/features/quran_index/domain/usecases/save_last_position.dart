import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../repositories/quran_repository.dart';

class SaveLastPosition {
  final QuranRepository repository;

  SaveLastPosition(this.repository);

  Future<Either<Failure, void>> call(int surahNumber, int ayahNumber) {
    return repository.saveLastPosition(surahNumber, ayahNumber);
  }
}
