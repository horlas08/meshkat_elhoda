import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/allah_name.dart';

abstract class AllahNamesRepository {
  Future<Either<Failure, List<AllahName>>> getAllahNames();
}
