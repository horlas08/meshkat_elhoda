import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../repositories/bookmark_repository.dart';

class DeleteBookmark {
  final BookmarkRepository repository;

  DeleteBookmark(this.repository);

  Future<Either<Failure, void>> call(String bookmarkId) {
    return repository.deleteBookmark(bookmarkId);
  }
}
