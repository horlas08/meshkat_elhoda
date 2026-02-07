import 'package:equatable/equatable.dart';

class AllahName extends Equatable {
  final int id;
  final String arabicName;
  final String transliteration;
  final String translation;

  const AllahName({
    required this.id,
    required this.arabicName,
    required this.transliteration,
    required this.translation,
  });

  @override
  List<Object?> get props => [id, arabicName, transliteration, translation];
}
