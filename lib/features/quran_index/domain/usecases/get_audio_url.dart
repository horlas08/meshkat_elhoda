import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/repositories/quran_repository.dart';

abstract class GetAudioUrl {
  final QuranRepository repository;

  GetAudioUrl(this.repository);

  Future<Either<Failure, String>> call(int surahNumber, String reciterId) {
    return repository.getAudioUrl(surahNumber, reciterId);
  }
}
