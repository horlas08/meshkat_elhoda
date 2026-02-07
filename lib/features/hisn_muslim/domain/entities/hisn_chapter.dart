
import 'package:equatable/equatable.dart';
import 'hisn_dhikr.dart';

class HisnChapter extends Equatable {
  final int id;
  final String title;
  final String audioUrl;
  final List<HisnDhikr> dhikrs;

  const HisnChapter({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.dhikrs,
  });

  @override
  List<Object?> get props => [id, title, audioUrl, dhikrs];
}
