import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';

class SaveFavoriteReciter {
  final QuranAudioRepository repository;

  SaveFavoriteReciter(this.repository);

  Future<Either<AppException, void>> call(Reciter reciter) {
    return repository.saveFavoriteReciter(reciter);
  }
}
