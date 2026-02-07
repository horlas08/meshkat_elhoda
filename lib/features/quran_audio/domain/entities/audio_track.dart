import 'package:equatable/equatable.dart';

class AudioTrack extends Equatable {
  final String surahNumber;
  final String surahName;
  final String reciterName;
  final String audioUrl;
  final int duration;
  final int ayahCount;

  const AudioTrack({
    required this.surahNumber,
    required this.surahName,
    required this.reciterName,
    required this.audioUrl,
    this.duration = 0,
    this.ayahCount = 0,
  });

  @override
  List<Object?> get props => [
    surahNumber,
    surahName,
    reciterName,
    audioUrl,
    duration,
    ayahCount,
  ];

  AudioTrack copyWith({
    String? surahNumber,
    String? surahName,
    String? reciterName,
    String? audioUrl,
    int? duration,
    int? ayahCount,
  }) {
    return AudioTrack(
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      reciterName: reciterName ?? this.reciterName,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      ayahCount: ayahCount ?? this.ayahCount,
    );
  }
}
