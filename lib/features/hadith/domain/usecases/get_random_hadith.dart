import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/hadith/domain/entities/hadith.dart';
import 'package:meshkat_elhoda/features/hadith/domain/repositories/hadith_repository.dart';

class GetRandomHadith {
  final HadithRepository repository;

  GetRandomHadith(this.repository);

  Future<Either<Failure, Hadith>> call({String? languageCode}) {
    return repository.getRandomHadith(languageCode: languageCode);
  }
}
