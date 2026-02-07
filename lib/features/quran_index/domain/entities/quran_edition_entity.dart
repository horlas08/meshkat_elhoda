import 'package:equatable/equatable.dart';

class QuranEditionEntity extends Equatable {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;
  final String? direction;

  const QuranEditionEntity({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    this.direction,
  });

  @override
  List<Object?> get props => [
    identifier,
    language,
    name,
    englishName,
    format,
    type,
    direction,
  ];
}
