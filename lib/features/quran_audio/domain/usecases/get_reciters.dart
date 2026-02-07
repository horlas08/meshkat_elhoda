import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';

class GetReciters {
  final QuranAudioRepository repository;

  GetReciters(this.repository);

  Future<Either<AppException, List<Reciter>>> call(String language) async {
    return await repository.getReciters(language);
  }
}
