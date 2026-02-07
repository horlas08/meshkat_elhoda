import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../repositories/bookmark_repository.dart';

class AddBookmark {
  final BookmarkRepository repository;

  AddBookmark(this.repository);

  Future<Either<Failure, void>> call({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required String ayahText,
    String? note,
  }) {
    return repository.addBookmark(
      surahNumber: surahNumber,
      surahName: surahName,
      ayahNumber: ayahNumber,
      ayahText: ayahText,
      note: note,
    );
  }
}
