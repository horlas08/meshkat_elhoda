import 'package:equatable/equatable.dart';

class DownloadedAudio extends Equatable {
  final String id;
  final String reciterName;
  final int surahNumber;
  final String surahName;
  final String localPath;
  final int fileSize;
  final String downloadedAt;

  const DownloadedAudio({
    required this.id,
    required this.reciterName,
    required this.surahNumber,
    required this.surahName,
    required this.localPath,
    required this.fileSize,
    required this.downloadedAt,
  });

  @override
  List<Object?> get props => [
    id,
    reciterName,
    surahNumber,
    surahName,
    localPath,
    fileSize,
    downloadedAt,
  ];
}
