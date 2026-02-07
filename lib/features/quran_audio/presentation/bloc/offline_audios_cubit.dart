import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/delete_offline_audio.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/get_offline_audios.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/offline_audios_state.dart';

class OfflineAudiosCubit extends Cubit<OfflineAudiosState> {
  final GetOfflineAudios getOfflineAudios;
  final DeleteOfflineAudio deleteOfflineAudio;

  OfflineAudiosCubit({
    required this.getOfflineAudios,
    required this.deleteOfflineAudio,
  }) : super(OfflineAudiosInitial());

  Future<void> loadOfflineAudios() async {
    emit(OfflineAudiosLoading());
    final result = await getOfflineAudios();
    result.fold(
      (failure) => emit(OfflineAudiosError(failure.message)),
      (audios) => emit(OfflineAudiosLoaded(audios)),
    );
  }

  Future<void> deleteAudio(String id) async {
    final result = await deleteOfflineAudio(id);
    result.fold(
      (failure) => emit(OfflineAudiosError(failure.message)),
      (_) => loadOfflineAudios(),
    );
  }
}
