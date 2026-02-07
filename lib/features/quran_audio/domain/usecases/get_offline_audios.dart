import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/downloaded_audio.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';

class GetOfflineAudios {
  final QuranAudioRepository repository;

  GetOfflineAudios(this.repository);

  Future<Either<AppException, List<DownloadedAudio>>> call() async {
    return await repository.getOfflineAudios();
  }
}
