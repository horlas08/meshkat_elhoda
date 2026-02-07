import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar_category.dart';

abstract class AzkarRepository {
  Future<Either<Failure, List<AzkarCategory>>> getAzkarCategories();
  Future<Either<Failure, List<Azkar>>> getAzkarItems(int categoryId);
  Future<Either<Failure, String>> getAzkarAudio(int azkarId);
}
