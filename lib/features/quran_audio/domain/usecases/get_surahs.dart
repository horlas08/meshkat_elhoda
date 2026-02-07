import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';

class GetSurahs {
  final QuranAudioRepository repository;

  GetSurahs(this.repository);

  Future<Either<AppException, List<Surah>>> call() async {
    return await repository.getSurahs();
  }
}
