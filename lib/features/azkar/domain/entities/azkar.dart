import 'package:equatable/equatable.dart';

class Azkar extends Equatable {
  final int id;
  final String title;
  final String text;
  final int? repeat;
  final String? audioUrl;
  final String? translation;
  final String? source;

  const Azkar({
    required this.id,
    required this.title,
    required this.text,
    this.repeat,
    this.audioUrl,
    this.translation,
    this.source,
  });

  @override
  List<Object?> get props => [id, title, text, repeat, audioUrl, translation, source];
}
