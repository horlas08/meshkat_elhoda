import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';

class DeleteOfflineAudio {
  final QuranAudioRepository repository;

  DeleteOfflineAudio(this.repository);

  Future<Either<AppException, void>> call(String id) async {
    return await repository.deleteOfflineAudio(id);
  }
}
