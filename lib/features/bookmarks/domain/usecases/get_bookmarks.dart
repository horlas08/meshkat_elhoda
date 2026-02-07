import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/bookmark_entity.dart';
import '../repositories/bookmark_repository.dart';

class GetBookmarks {
  final BookmarkRepository repository;

  GetBookmarks(this.repository);

  Future<Either<Failure, List<BookmarkEntity>>> call() {
    return repository.getBookmarks();
  }
}
