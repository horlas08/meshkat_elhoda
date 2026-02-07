import 'package:equatable/equatable.dart';

abstract class MosqueEvent extends Equatable {
  const MosqueEvent();

  @override
  List<Object?> get props => [];
}

class GetNearbyMosques extends MosqueEvent {
  const GetNearbyMosques();
}
