class JuzEntity {
  final int number;
  final List<JuzSurah> surahs;

  const JuzEntity({required this.number, required this.surahs});
}

class JuzSurah {
  final int number;
  final String name;
  final int startAyah;
  final int endAyah;

  const JuzSurah({
    required this.number,
    required this.name,
    required this.startAyah,
    required this.endAyah,
  });
}
