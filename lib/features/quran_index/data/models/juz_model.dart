import '../../domain/entities/juz_entity.dart';

class JuzModel extends JuzEntity {
  const JuzModel({required super.number, required super.surahs});

  factory JuzModel.fromJson(Map<String, dynamic> json) {
    final ayahs = json['ayahs'] as List;
    final Map<int, List<dynamic>> ayahsBySurah = {};

    for (var ayah in ayahs) {
      final surahNum = ayah['surah']['number'];
      if (!ayahsBySurah.containsKey(surahNum)) {
        ayahsBySurah[surahNum] = [];
      }
      ayahsBySurah[surahNum]!.add(ayah);
    }

    final List<JuzSurahModel> surahsList = [];

    ayahsBySurah.forEach((surahNum, surahAyahs) {
      final firstAyah = surahAyahs.first;
      final surahName = firstAyah['surah']['name'];

      // Find start and end ayah numbers in this juz
      int start = surahAyahs.first['numberInSurah'];
      int end = surahAyahs.first['numberInSurah'];

      for (var a in surahAyahs) {
        final num = a['numberInSurah'] as int;
        if (num < start) start = num;
        if (num > end) end = num;
      }

      surahsList.add(
        JuzSurahModel(
          number: surahNum,
          name: surahName,
          startAyah: start,
          endAyah: end,
        ),
      );
    });

    return JuzModel(number: json['number'], surahs: surahsList);
  }
}

class JuzSurahModel extends JuzSurah {
  const JuzSurahModel({
    required super.number,
    required super.name,
    required super.startAyah,
    required super.endAyah,
  });

  factory JuzSurahModel.fromJson(Map<String, dynamic> json) {
    return JuzSurahModel(
      number: json['number'],
      name: json['name'],
      startAyah: json['startAyah'],
      endAyah: json['endAyah'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'startAyah': startAyah,
      'endAyah': endAyah,
    };
  }
}
