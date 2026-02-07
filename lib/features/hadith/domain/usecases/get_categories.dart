import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/hadith/data/models/hadith_category_model.dart';
import 'package:meshkat_elhoda/features/hadith/domain/repositories/hadith_repository.dart';

class GetCategories {
  final HadithRepository repository;

  GetCategories(this.repository);

  /// Get root categories
  Future<Either<Failure, List<HadithCategory>>> getRootCategories({
    String? languageCode,
  }) {
    return repository.getRootCategories(languageCode: languageCode);
  }

  /// Get all categories
  Future<Either<Failure, List<HadithCategory>>> getAllCategories({
    String? languageCode,
  }) {
    return repository.getCategories(languageCode: languageCode);
  }

  /// Get sub-categories
  Future<Either<Failure, List<HadithCategory>>> getSubCategories({
    required String parentId,
    String? languageCode,
  }) {
    return repository.getSubCategories(
      parentId: parentId,
      languageCode: languageCode,
    );
  }
}
