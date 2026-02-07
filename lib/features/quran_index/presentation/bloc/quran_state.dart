import 'package:equatable/equatable.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/entities/juz_entity.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/entities/tafsir_entity.dart';

abstract class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object?> get props => [];
}

class QuranInitial extends QuranState {}

class Loading extends QuranState {}

class Error extends QuranState {
  final String message;

  const Error(this.message);

  @override
  List<Object?> get props => [message];
}

class SurahsLoaded extends QuranState {
  final List<SurahEntity> surahs;

  const SurahsLoaded(this.surahs);

  @override
  List<Object?> get props => [surahs];
}

class SurahAyahsLoaded extends QuranState {
  final List<AyahEntity> ayahs;

  const SurahAyahsLoaded(this.ayahs);

  @override
  List<Object?> get props => [ayahs];
}

class JuzLoaded extends QuranState {
  final JuzEntity juz;

  const JuzLoaded(this.juz);

  @override
  List<Object?> get props => [juz];
}

class TafsirLoaded extends QuranState {
  final TafsirEntity tafsir;

  const TafsirLoaded(this.tafsir);

  @override
  List<Object?> get props => [tafsir];
}

class RecitersLoaded extends QuranState {
  final List<ReciterEntity> reciters;

  const RecitersLoaded(this.reciters);

  @override
  List<Object?> get props => [reciters];
}

class AudioUrlLoaded extends QuranState {
  final String url;

  const AudioUrlLoaded(this.url);

  @override
  List<Object?> get props => [url];
}

class LastPositionLoaded extends QuranState {
  final int surahNumber;
  final int ayahNumber;

  const LastPositionLoaded({
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  List<Object?> get props => [surahNumber, ayahNumber];
}

class LastPositionSaved extends QuranState {}

class SearchResultsLoaded extends QuranState {
  final List<SurahEntity> searchResults;

  const SearchResultsLoaded(this.searchResults);

  @override
  List<Object?> get props => [searchResults];
}
