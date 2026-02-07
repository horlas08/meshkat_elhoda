import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/download_surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/surah_download_state.dart';

class SurahDownloadCubit extends Cubit<SurahDownloadState> {
  final DownloadSurah downloadSurah;

  SurahDownloadCubit(this.downloadSurah) : super(SurahDownloadInitial());

  Future<void> download(Surah surah, Reciter reciter) async {
    emit(SurahDownloadLoading());
    final result = await downloadSurah(surah, reciter);
    result.fold(
      (failure) => emit(SurahDownloadError(failure.message)),
      (_) => emit(SurahDownloadSuccess()),
    );
  }
}
