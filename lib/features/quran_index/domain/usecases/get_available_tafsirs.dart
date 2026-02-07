import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/quran_edition_entity.dart';
import '../repositories/quran_repository.dart';

class GetAvailableTafsirs {
  final QuranRepository repository;

  GetAvailableTafsirs(this.repository);

  Future<Either<Failure, List<QuranEditionEntity>>> call(
    String language,
  ) async {
    return await repository.getAvailableTafsirs(language);
  }
}
