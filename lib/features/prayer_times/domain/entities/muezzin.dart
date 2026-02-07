import 'package:equatable/equatable.dart';

class Muezzin extends Equatable {
  final String id;
  final String name;
  final String fajrAudioPath;
  final String regularAudioPath;

  const Muezzin({
    required this.id,
    required this.name,
    required this.fajrAudioPath,
    required this.regularAudioPath,
  });

  @override
  List<Object?> get props => [id, name, fajrAudioPath, regularAudioPath];
}
