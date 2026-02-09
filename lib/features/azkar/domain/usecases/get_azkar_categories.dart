import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar_category.dart';
import 'package:meshkat_elhoda/features/azkar/domain/repositories/azkar_repository.dart';

class GetAzkarCategories {
  final AzkarRepository repository;

  GetAzkarCategories(this.repository);

  Future<Either<Failure, List<AzkarCategory>>> call(String languageCode) async {
    return await repository.getAzkarCategories(languageCode);
  }
}
