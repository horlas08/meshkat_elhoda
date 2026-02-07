import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/core/network/network_info.dart';
import '../../domain/entities/bookmark_entity.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_local_data_source.dart';
import '../datasources/bookmark_remote_data_source.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkRemoteDataSource remoteDataSource;
  final BookmarkLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  BookmarkRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> addBookmark({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required String ayahText,
    String? note,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addBookmark(
          surahNumber: surahNumber,
          surahName: surahName,
          ayahNumber: ayahNumber,
          ayahText: ayahText,
          note: note,
        );
        
        // Refresh cache after adding
        final bookmarks = await remoteDataSource.getBookmarks();
        await localDataSource.cacheBookmarks(bookmarks);
        
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<Either<Failure, List<BookmarkEntity>>> getBookmarks() async {
    if (await networkInfo.isConnected) {
      try {
        final bookmarks = await remoteDataSource.getBookmarks();
        await localDataSource.cacheBookmarks(bookmarks);
        return Right(bookmarks);
      } catch (e) {
        // If remote fails, try to get cached data
        try {
          final cachedBookmarks = await localDataSource.getCachedBookmarks();
          return Right(cachedBookmarks);
        } catch (cacheError) {
          return Left(ServerFailure(message: e.toString()));
        }
      }
    } else {
      // No internet, get cached data
      try {
        final cachedBookmarks = await localDataSource.getCachedBookmarks();
        return Right(cachedBookmarks);
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteBookmark(String bookmarkId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteBookmark(bookmarkId);
        
        // Refresh cache after deleting
        final bookmarks = await remoteDataSource.getBookmarks();
        await localDataSource.cacheBookmarks(bookmarks);
        
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isBookmarked({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.isBookmarked(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
        );
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Check in cached data
      try {
        final cachedBookmarks = await localDataSource.getCachedBookmarks();
        final isBookmarked = cachedBookmarks.any(
          (bookmark) =>
              bookmark.surahNumber == surahNumber &&
              bookmark.ayahNumber == ayahNumber,
        );
        return Right(isBookmarked);
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String?>> getBookmarkId({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final bookmarkId = await remoteDataSource.getBookmarkId(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
        );
        return Right(bookmarkId);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Check in cached data
      try {
        final cachedBookmarks = await localDataSource.getCachedBookmarks();
        try {
          final bookmark = cachedBookmarks.firstWhere(
            (bookmark) =>
                bookmark.surahNumber == surahNumber &&
                bookmark.ayahNumber == ayahNumber,
          );
          return Right(bookmark.id);
        } catch (e) {
          return const Right(null);
        }
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }
}
