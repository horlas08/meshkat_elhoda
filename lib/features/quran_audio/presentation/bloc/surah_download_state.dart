import 'package:equatable/equatable.dart';

abstract class SurahDownloadState extends Equatable {
  const SurahDownloadState();

  @override
  List<Object> get props => [];
}

class SurahDownloadInitial extends SurahDownloadState {}

class SurahDownloadLoading extends SurahDownloadState {}

class SurahDownloadSuccess extends SurahDownloadState {}

class SurahDownloadError extends SurahDownloadState {
  final String message;

  const SurahDownloadError(this.message);

  @override
  List<Object> get props => [message];
}
