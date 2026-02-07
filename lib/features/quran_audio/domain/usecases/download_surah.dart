import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';

class DownloadSurah {
  final QuranAudioRepository repository;

  DownloadSurah(this.repository);

  Future<Either<AppException, void>> call(Surah surah, Reciter reciter) async {
    return await repository.downloadSurah(surah, reciter);
  }
}
