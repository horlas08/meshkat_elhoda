import 'package:equatable/equatable.dart';
import '../../domain/entities/bookmark_entity.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {
  const BookmarkInitial();
}

class BookmarkLoading extends BookmarkState {
  const BookmarkLoading();
}

class BookmarkActionLoading extends BookmarkState {
  const BookmarkActionLoading();
}

class BookmarksLoaded extends BookmarkState {
  final List<BookmarkEntity> bookmarks;

  const BookmarksLoaded(this.bookmarks);

  @override
  List<Object> get props => [bookmarks];
}

class BookmarkAdded extends BookmarkState {
  const BookmarkAdded();
}

class BookmarkDeleted extends BookmarkState {
  const BookmarkDeleted();
}

class BookmarkStatusChecked extends BookmarkState {
  final bool isBookmarked;
  final String? bookmarkId;

  const BookmarkStatusChecked({
    required this.isBookmarked,
    this.bookmarkId,
  });

  @override
  List<Object?> get props => [isBookmarked, bookmarkId];
}

class BookmarkError extends BookmarkState {
  final String message;

  const BookmarkError(this.message);

  @override
  List<Object> get props => [message];
}
