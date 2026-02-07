import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/bookmark_entity.dart';

abstract class BookmarkRepository {
  /// Add a new bookmark to Firestore
  Future<Either<Failure, void>> addBookmark({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required String ayahText,
    String? note,
  });

  /// Fetch all bookmarks for the current user
  Future<Either<Failure, List<BookmarkEntity>>> getBookmarks();

  /// Delete a specific bookmark
  Future<Either<Failure, void>> deleteBookmark(String bookmarkId);

  /// Check if a specific ayah is bookmarked
  Future<Either<Failure, bool>> isBookmarked({
    required int surahNumber,
    required int ayahNumber,
  });

  /// Get bookmark ID for a specific ayah (if exists)
  Future<Either<Failure, String?>> getBookmarkId({
    required int surahNumber,
    required int ayahNumber,
  });
}
