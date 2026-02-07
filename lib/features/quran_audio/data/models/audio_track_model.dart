import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';

class AudioTrackModel extends AudioTrack {
  const AudioTrackModel({
    required super.surahNumber,
    required super.surahName,
    required super.reciterName,
    required super.audioUrl,
    super.duration = 0,
    super.ayahCount = 0,
  });

  factory AudioTrackModel.fromJson(Map<String, dynamic> json) {
    return AudioTrackModel(
      surahNumber: json['surahNumber'] as String? ?? '',
      surahName: json['surahName'] as String? ?? '',
      reciterName: json['reciterName'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      duration: int.tryParse(json['duration'].toString()) ?? 0,
      ayahCount: int.tryParse(json['ayahCount'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'reciterName': reciterName,
      'audioUrl': audioUrl,
      'duration': duration,
      'ayahCount': ayahCount,
    };
  }

  AudioTrackModel copyWith({
    String? surahNumber,
    String? surahName,
    String? reciterName,
    String? audioUrl,
    int? duration,
    int? ayahCount,
  }) {
    return AudioTrackModel(
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      reciterName: reciterName ?? this.reciterName,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      ayahCount: ayahCount ?? this.ayahCount,
    );
  }
}
