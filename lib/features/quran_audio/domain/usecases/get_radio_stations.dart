import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/radio_station.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';

class GetRadioStations {
  final QuranAudioRepository repository;

  GetRadioStations(this.repository);

  Future<Either<AppException, List<RadioStation>>> call() async {
    return await repository.getRadioStations();
  }
}
