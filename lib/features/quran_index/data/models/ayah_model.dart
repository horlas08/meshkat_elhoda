import '../../domain/entities/ayah_entity.dart';

class AyahModel extends AyahEntity {
  const AyahModel({
    required super.number,
    required super.text,
    required super.numberInSurah,
    required super.juz,
    required super.manzil,
    required super.page,
    required super.ruku,
    required super.hizbQuarter,
    required super.sajda,
    required super.audio,
    super.translation,
  });

  factory AyahModel.fromJson(
    Map<String, dynamic> json, {
    int? surahNumber,
    String? translationText,
  }) {
    String text = json['text'] ?? '';
    // إذا لم تكن الفاتحة والأية الأولى تبدأ ببسم الله الرحمن الرحيم، احذفها
    if (surahNumber != null && surahNumber != 1 && json['numberInSurah'] == 1) {
      const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
      if (text.trim().startsWith(bismillah)) {
        print('[AyahModel] Removing Basmala from surah $surahNumber, ayah 1');
        print('[AyahModel] Original: $text');
        text = text.trim().substring(bismillah.length).trimLeft();
        print('[AyahModel] After: $text');
      } else {
        print('[AyahModel] No Basmala found in surah $surahNumber, ayah 1');
      }
    }
    return AyahModel(
      number: json['number'],
      text: text,
      numberInSurah: json['numberInSurah'],
      juz: json['juz'],
      manzil: json['manzil'],
      page: json['page'],
      ruku: json['ruku'],
      hizbQuarter: json['hizbQuarter'],
      sajda: json['sajda'] is Map ? (json['sajda'] as Map).isNotEmpty : false,
      audio: json['audio'] ?? '',
      translation: translationText,
    );
  }

  /// ✅ نسخة محدثة من الموديل مع إضافة الترجمة
  AyahModel copyWithTranslation(String? translation) {
    return AyahModel(
      number: number,
      text: text,
      numberInSurah: numberInSurah,
      juz: juz,
      manzil: manzil,
      page: page,
      ruku: ruku,
      hizbQuarter: hizbQuarter,
      sajda: sajda,
      audio: audio,
      translation: translation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'numberInSurah': numberInSurah,
      'juz': juz,
      'manzil': manzil,
      'page': page,
      'ruku': ruku,
      'hizbQuarter': hizbQuarter,
      'sajda': sajda,
      'audio': audio,
      'translation': translation,
    };
  }
}
