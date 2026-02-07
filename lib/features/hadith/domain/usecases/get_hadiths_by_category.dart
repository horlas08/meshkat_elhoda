import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/hadith/data/models/hadith_category_model.dart';
import 'package:meshkat_elhoda/features/hadith/domain/repositories/hadith_repository.dart';

class GetHadithsByCategory {
  final HadithRepository repository;

  GetHadithsByCategory(this.repository);

  Future<Either<Failure, HadithListResponse>> call({
    required String categoryId,
    int page = 1,
    int perPage = 20,
    String? languageCode,
  }) {
    return repository.getHadithsByCategory(
      categoryId: categoryId,
      page: page,
      perPage: perPage,
      languageCode: languageCode,
    );
  }
}
