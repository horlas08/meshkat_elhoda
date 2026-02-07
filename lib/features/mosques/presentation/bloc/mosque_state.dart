import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/mosques/domain/entities/mosque.dart';

abstract class MosqueState extends Equatable {
  const MosqueState();

  @override
  List<Object?> get props => [];
}

class MosqueInitial extends MosqueState {
  const MosqueInitial();
}

class MosqueLoading extends MosqueState {
  const MosqueLoading();
}

class MosqueLoaded extends MosqueState {
  final List<Mosque> mosques;
  final double userLatitude;
  final double userLongitude;

  const MosqueLoaded({
    required this.mosques,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  List<Object?> get props => [mosques, userLatitude, userLongitude];
}

class MosqueError extends MosqueState {
  final String message;
  const MosqueError(this.message);

  @override
  List<Object?> get props => [message];
}
