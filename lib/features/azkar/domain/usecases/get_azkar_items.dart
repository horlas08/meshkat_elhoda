import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar.dart';
import 'package:meshkat_elhoda/features/azkar/domain/repositories/azkar_repository.dart';

class GetAzkarItems {
  final AzkarRepository repository;

  GetAzkarItems(this.repository);

  Future<Either<Failure, List<Azkar>>> call(int chapterId) async {
    return await repository.getAzkarItems(chapterId);
  }
}
