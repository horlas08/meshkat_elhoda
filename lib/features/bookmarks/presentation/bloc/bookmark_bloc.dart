import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_bookmark.dart';
import '../../domain/usecases/delete_bookmark.dart';
import '../../domain/usecases/get_bookmark_id.dart';
import '../../domain/usecases/get_bookmarks.dart';
import '../../domain/usecases/is_bookmarked.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final AddBookmark addBookmark;
  final GetBookmarks getBookmarks;
  final DeleteBookmark deleteBookmark;
  final IsBookmarked isBookmarked;
  final GetBookmarkId getBookmarkId;

  BookmarkBloc({
    required this.addBookmark,
    required this.getBookmarks,
    required this.deleteBookmark,
    required this.isBookmarked,
    required this.getBookmarkId,
  }) : super(const BookmarkInitial()) {
    on<AddBookmarkEvent>(_onAddBookmark);
    on<GetBookmarksEvent>(_onGetBookmarks);
    on<DeleteBookmarkEvent>(_onDeleteBookmark);
    on<CheckBookmarkStatusEvent>(_onCheckBookmarkStatus);
  }

  Future<void> _onAddBookmark(
    AddBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(const BookmarkActionLoading());

    final result = await addBookmark(
      surahNumber: event.surahNumber,
      surahName: event.surahName,
      ayahNumber: event.ayahNumber,
      ayahText: event.ayahText,
      note: event.note,
    );

    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (_) => emit(const BookmarkAdded()),
    );
  }

  Future<void> _onGetBookmarks(
    GetBookmarksEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(const BookmarkLoading());

    final result = await getBookmarks();

    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (bookmarks) => emit(BookmarksLoaded(bookmarks)),
    );
  }

  Future<void> _onDeleteBookmark(
    DeleteBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(const BookmarkActionLoading());

    final result = await deleteBookmark(event.bookmarkId);

    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (_) => emit(const BookmarkDeleted()),
    );
  }

  Future<void> _onCheckBookmarkStatus(
    CheckBookmarkStatusEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    final isBookmarkedResult = await isBookmarked(
      surahNumber: event.surahNumber,
      ayahNumber: event.ayahNumber,
    );

    await isBookmarkedResult.fold(
      (failure) async => emit(BookmarkError(failure.message)),
      (bookmarked) async {
        if (bookmarked) {
          final bookmarkIdResult = await getBookmarkId(
            surahNumber: event.surahNumber,
            ayahNumber: event.ayahNumber,
          );

          bookmarkIdResult.fold(
            (failure) => emit(BookmarkError(failure.message)),
            (bookmarkId) => emit(
              BookmarkStatusChecked(
                isBookmarked: true,
                bookmarkId: bookmarkId,
              ),
            ),
          );
        } else {
          emit(const BookmarkStatusChecked(isBookmarked: false));
        }
      },
    );
  }
}
