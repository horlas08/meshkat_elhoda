import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../repositories/bookmark_repository.dart';

class IsBookmarked {
  final BookmarkRepository repository;

  IsBookmarked(this.repository);

  Future<Either<Failure, bool>> call({
    required int surahNumber,
    required int ayahNumber,
  }) {
    return repository.isBookmarked(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
  }
}
