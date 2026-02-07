import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../repositories/bookmark_repository.dart';

class GetBookmarkId {
  final BookmarkRepository repository;

  GetBookmarkId(this.repository);

  Future<Either<Failure, String?>> call({
    required int surahNumber,
    required int ayahNumber,
  }) {
    return repository.getBookmarkId(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
  }
}
