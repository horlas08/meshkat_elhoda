import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/allah_name.dart';
import 'package:meshkat_elhoda/features/azkar/domain/repositories/allah_names_repository.dart';

class GetAllahNames {
  final AllahNamesRepository repository;

  GetAllahNames(this.repository);

  Future<Either<Failure, List<AllahName>>> call() async {
    return await repository.getAllahNames();
  }
}
