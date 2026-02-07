import 'package:equatable/equatable.dart';

abstract class KhatmahEvent extends Equatable {
  const KhatmahEvent();

  @override
  List<Object?> get props => [];
}

class LoadKhatmah extends KhatmahEvent {}

class UpdatePage extends KhatmahEvent {
  final int pageNumber;
  const UpdatePage(this.pageNumber);

  @override
  List<Object> get props => [pageNumber];
}

class ToggleAudio extends KhatmahEvent {}

class NextAyahAudio extends KhatmahEvent {}

class PauseAudio extends KhatmahEvent {}
