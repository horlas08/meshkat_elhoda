import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';

class AddToRecentlyPlayed {
  final QuranAudioRepository repository;

  AddToRecentlyPlayed(this.repository);

  Future<Either<AppException, void>> call(AudioTrack track) {
    return repository.addToRecentlyPlayed(track);
  }
}
