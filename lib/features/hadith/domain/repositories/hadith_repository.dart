import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/hadith/domain/entities/hadith.dart';
import 'package:meshkat_elhoda/features/hadith/data/models/hadith_category_model.dart';

abstract class HadithRepository {
  /// Get all available languages
  Future<Either<Failure, List<Map<String, String>>>> getLanguages();

  /// Get root categories (main categories)
  Future<Either<Failure, List<HadithCategory>>> getRootCategories({
    String? languageCode,
  });

  /// Get all categories
  Future<Either<Failure, List<HadithCategory>>> getCategories({
    String? languageCode,
  });

  /// Get sub-categories for a parent category
  Future<Either<Failure, List<HadithCategory>>> getSubCategories({
    required String parentId,
    String? languageCode,
  });

  /// Get hadiths by category with pagination
  Future<Either<Failure, HadithListResponse>> getHadithsByCategory({
    required String categoryId,
    int page = 1,
    int perPage = 20,
    String? languageCode,
  });

  /// Get single hadith details
  Future<Either<Failure, Hadith>> getHadithById({
    required String id,
    String? languageCode,
  });

  /// Get random hadith
  Future<Either<Failure, Hadith>> getRandomHadith({String? languageCode});

  /// Get current user language
  Future<String> getCurrentUserLanguage();

  /// Clear cache
  void clearCache();
}
