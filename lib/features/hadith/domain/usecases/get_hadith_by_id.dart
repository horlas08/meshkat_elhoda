import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/hadith/domain/entities/hadith.dart';
import 'package:meshkat_elhoda/features/hadith/domain/repositories/hadith_repository.dart';

class GetHadithById {
  final HadithRepository repository;

  GetHadithById(this.repository);

  Future<Either<Failure, Hadith>> call({
    required String id,
    String? languageCode,
  }) {
    return repository.getHadithById(id: id, languageCode: languageCode);
  }
}
