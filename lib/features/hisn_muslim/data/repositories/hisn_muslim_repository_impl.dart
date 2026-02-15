
import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../../domain/entities/hisn_chapter.dart';
import '../../domain/repositories/hisn_repository.dart';
import '../datasources/hisn_muslim_local_data_source.dart';

class HisnMuslimRepositoryImpl implements HisnMuslimRepository {
  final HisnMuslimLocalDataSource localDataSource;

  HisnMuslimRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<HisnChapter>>> getChapters(String languageCode) async {
    try {
      final chapters = await localDataSource.getHisnCategories(languageCode);
      return Right(chapters);
    } catch (e) {
      return Left(CacheFailure(message: "Failed to load chapters"));
    }
  }
}
