import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/entities/ayah_entity.dart';

class PageDetailsEntity extends Equatable {
  final int pageNumber;
  final String surahName;
  final String surahNameEnglish;
  final int juz;
  final int hizb;
  final int manzil;
  final int ruku;
  final int totalAyahsInSurah;
  final List<AyahEntity> ayahs;

  const PageDetailsEntity({
    required this.pageNumber,
    required this.surahName,
    required this.surahNameEnglish,
    required this.juz,
    required this.hizb,
    required this.manzil,
    required this.ruku,
    required this.totalAyahsInSurah,
    required this.ayahs,
  });

  @override
  List<Object?> get props => [
    pageNumber,
    surahName,
    surahNameEnglish,
    juz,
    hizb,
    manzil,
    ruku,
    totalAyahsInSurah,
    ayahs,
  ];
}
