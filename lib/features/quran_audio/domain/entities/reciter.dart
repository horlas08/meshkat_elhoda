import 'package:equatable/equatable.dart';

class Reciter extends Equatable {
  final String id;
  final String name;
  final String server;
  final String rewaya;
  final int count;
  final String letter;
  final String suras;
  final bool isFavorite;

  const Reciter({
    required this.id,
    required this.name,
    required this.server,
    required this.rewaya,
    required this.count,
    required this.letter,
    required this.suras,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    server,
    rewaya,
    count,
    letter,
    suras,
    isFavorite,
  ];

  Reciter copyWith({
    String? id,
    String? name,
    String? server,
    String? rewaya,
    int? count,
    String? letter,
    String? suras,
    bool? isFavorite,
  }) {
    return Reciter(
      id: id ?? this.id,
      name: name ?? this.name,
      server: server ?? this.server,
      rewaya: rewaya ?? this.rewaya,
      count: count ?? this.count,
      letter: letter ?? this.letter,
      suras: suras ?? this.suras,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
