import 'package:equatable/equatable.dart';

abstract class AzkarEvent extends Equatable {
  const AzkarEvent();

  @override
  List<Object?> get props => [];
}

class FetchAzkarCategories extends AzkarEvent {
  const FetchAzkarCategories();
}

class FetchAzkarChapters extends AzkarEvent {
  final int categoryId;

  const FetchAzkarChapters(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class FetchAzkarItems extends AzkarEvent {
  final int chapterId;

  const FetchAzkarItems(this.chapterId);

  @override
  List<Object?> get props => [chapterId];
}

class FetchAllahNames extends AzkarEvent {
  const FetchAllahNames();
}

class PlayAzkarAudio extends AzkarEvent {
  final int azkarId;

  const PlayAzkarAudio(this.azkarId);

  @override
  List<Object?> get props => [azkarId];
}
