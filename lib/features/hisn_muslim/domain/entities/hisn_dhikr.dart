
import 'package:equatable/equatable.dart';

class HisnDhikr extends Equatable {
  final int id;
  final String arabicText;
  final String translatedText; // English from JSON
  final int repeat;
  final String audio;

  const HisnDhikr({
    required this.id,
    required this.arabicText,
    required this.translatedText,
    required this.repeat,
    required this.audio,
  });

  @override
  List<Object?> get props => [id, arabicText, translatedText, repeat, audio];
}
