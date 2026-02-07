import 'package:meshkat_elhoda/features/quran_audio/domain/entities/downloaded_audio.dart';

class DownloadedAudioModel extends DownloadedAudio {
  const DownloadedAudioModel({
    required super.id,
    required super.reciterName,
    required super.surahNumber,
    required super.surahName,
    required super.localPath,
    required super.fileSize,
    required super.downloadedAt,
  });

  factory DownloadedAudioModel.fromJson(Map<String, dynamic> json) {
    return DownloadedAudioModel(
      id: json['id'] as String,
      reciterName: json['reciter'] as String,
      surahNumber: json['surahNumber'] as int,
      surahName: json['surahName'] as String,
      localPath: json['localPath'] as String,
      fileSize: json['fileSize'] as int,
      downloadedAt: json['downloadedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reciter': reciterName,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'localPath': localPath,
      'fileSize': fileSize,
      'downloadedAt': downloadedAt,
    };
  }

  factory DownloadedAudioModel.fromEntity(DownloadedAudio entity) {
    return DownloadedAudioModel(
      id: entity.id,
      reciterName: entity.reciterName,
      surahNumber: entity.surahNumber,
      surahName: entity.surahName,
      localPath: entity.localPath,
      fileSize: entity.fileSize,
      downloadedAt: entity.downloadedAt,
    );
  }
}
