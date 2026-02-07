import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/reciter_entity.dart';
import '../repositories/quran_repository.dart';

class GetReciters {
  final QuranRepository repository;

  GetReciters(this.repository);

  Future<Either<Failure, List<ReciterEntity>>> call() {
    return repository.getReciters();
  }
}
