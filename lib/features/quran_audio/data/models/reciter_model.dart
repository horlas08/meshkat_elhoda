import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';

class ReciterModel extends Reciter {
  const ReciterModel({
    required super.id,
    required super.name,
    required super.server,
    required super.rewaya,
    required super.count,
    required super.letter,
    required super.suras,
    super.isFavorite = false,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    return ReciterModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      server: json['Server'] as String? ?? '',
      rewaya: json['rewaya'] as String? ?? '',
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      letter: json['letter'] as String? ?? '',
      suras: json['suras'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'Server': server,
      'rewaya': rewaya,
      'count': count.toString(),
      'letter': letter,
      'suras': suras,
    };
  }

  ReciterModel copyWith({
    String? id,
    String? name,
    String? server,
    String? rewaya,
    int? count,
    String? letter,
    String? suras,
    bool? isFavorite,
  }) {
    return ReciterModel(
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
