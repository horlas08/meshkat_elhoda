import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/downloaded_audio.dart';

abstract class OfflineAudiosState extends Equatable {
  const OfflineAudiosState();

  @override
  List<Object> get props => [];
}

class OfflineAudiosInitial extends OfflineAudiosState {}

class OfflineAudiosLoading extends OfflineAudiosState {}

class OfflineAudiosLoaded extends OfflineAudiosState {
  final List<DownloadedAudio> audios;

  const OfflineAudiosLoaded(this.audios);

  @override
  List<Object> get props => [audios];
}

class OfflineAudiosError extends OfflineAudiosState {
  final String message;

  const OfflineAudiosError(this.message);

  @override
  List<Object> get props => [message];
}
