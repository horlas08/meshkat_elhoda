
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/hisn_chapter.dart';

abstract class HisnMuslimRepository {
  Future<Either<Failure, List<HisnChapter>>> getChapters();
}
