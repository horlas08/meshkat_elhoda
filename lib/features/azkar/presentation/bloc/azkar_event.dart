import 'package:equatable/equatable.dart';

abstract class AzkarEvent extends Equatable {
  const AzkarEvent();

  @override
  List<Object?> get props => [];
}

class FetchAzkarCategories extends AzkarEvent {
  final String languageCode;
  const FetchAzkarCategories(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class FetchAzkarChapters extends AzkarEvent {
  final int categoryId;
  final String languageCode;

  const FetchAzkarChapters(this.categoryId, this.languageCode);

  @override
  List<Object?> get props => [categoryId, languageCode];
}

class FetchAzkarItems extends AzkarEvent {
  final int chapterId;
  final String languageCode;

  const FetchAzkarItems(this.chapterId, this.languageCode);

  @override
  List<Object?> get props => [chapterId, languageCode];
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
