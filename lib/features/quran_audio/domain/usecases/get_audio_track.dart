import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';

class GetAudioTrack {
  final QuranAudioRepository repository;

  GetAudioTrack(this.repository);

  Future<Either<AppException, AudioTrack>> call(Reciter reciter, Surah surah) {
    return repository.getAudioTrack(reciter, surah);
  }
}
