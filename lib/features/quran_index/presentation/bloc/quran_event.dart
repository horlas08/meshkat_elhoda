import 'package:equatable/equatable.dart';

abstract class QuranEvent extends Equatable {
  const QuranEvent();

  @override
  List<Object?> get props => [];
}

class GetAllSurahsEvent extends QuranEvent {}

class GetSurahByNumberEvent extends QuranEvent {
  final int number;
  final String? reciterId;
  final String? language;

  const GetSurahByNumberEvent({
    required this.number,
    this.reciterId,
    this.language,
  });

  @override
  List<Object?> get props => [number, reciterId, language];
}

class GetJuzSurahsEvent extends QuranEvent {
  final int number;

  const GetJuzSurahsEvent({required this.number});

  @override
  List<Object?> get props => [number];
}

class GetAyahTafsirEvent extends QuranEvent {
  final int surahNumber;
  final int ayahNumber;
  final String language;
  final String? tafsirId;

  const GetAyahTafsirEvent({
    required this.surahNumber,
    required this.ayahNumber,
    required this.language,
    this.tafsirId,
  });

  @override
  List<Object?> get props => [surahNumber, ayahNumber, language, tafsirId];
}

class GetRecitersEvent extends QuranEvent {}

class GetAudioUrlEvent extends QuranEvent {
  final int surahNumber;
  final String reciterId;

  const GetAudioUrlEvent({required this.surahNumber, required this.reciterId});

  @override
  List<Object?> get props => [surahNumber, reciterId];
}

class SaveLastPositionEvent extends QuranEvent {
  final int surahNumber;
  final int ayahNumber;

  const SaveLastPositionEvent({
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  List<Object?> get props => [surahNumber, ayahNumber];
}

class GetLastPositionEvent extends QuranEvent {}

class ResetStateEvent extends QuranEvent {}

// داخل QuranEvent
class ClearTafsirEvent extends QuranEvent {}

class SearchSurahsEvent extends QuranEvent {
  final String query;
  final List<dynamic> allSurahs;

  const SearchSurahsEvent({required this.query, required this.allSurahs});

  @override
  List<Object?> get props => [query, allSurahs];
}

class GetAllQuranAyahsEvent extends QuranEvent {
  final String? reciterId;

  const GetAllQuranAyahsEvent({this.reciterId});

  @override
  List<Object?> get props => [reciterId];
}
