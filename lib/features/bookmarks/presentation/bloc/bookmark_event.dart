import 'package:equatable/equatable.dart';

abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object?> get props => [];
}

class AddBookmarkEvent extends BookmarkEvent {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final String? note;

  const AddBookmarkEvent({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    this.note,
  });

  @override
  List<Object?> get props => [
        surahNumber,
        surahName,
        ayahNumber,
        ayahText,
        note,
      ];
}

class GetBookmarksEvent extends BookmarkEvent {
  const GetBookmarksEvent();
}

class DeleteBookmarkEvent extends BookmarkEvent {
  final String bookmarkId;

  const DeleteBookmarkEvent(this.bookmarkId);

  @override
  List<Object> get props => [bookmarkId];
}

class CheckBookmarkStatusEvent extends BookmarkEvent {
  final int surahNumber;
  final int ayahNumber;

  const CheckBookmarkStatusEvent({
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  List<Object> get props => [surahNumber, ayahNumber];
}
