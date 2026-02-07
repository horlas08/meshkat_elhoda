import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../../domain/repositories/quran_repository.dart';
import '../../domain/usecases/get_audio_url.dart';

class GetAudioUrlImpl implements GetAudioUrl {
  final QuranRepository repository;

  GetAudioUrlImpl(this.repository);

  @override
  Future<Either<Failure, String>> call(
    int surahNumber,
    String reciterId,
  ) async {
    return repository.getAudioUrl(surahNumber, reciterId);
  }
}
