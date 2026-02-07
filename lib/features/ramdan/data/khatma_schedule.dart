/// جدول ختم القرآن في رمضان
/// يحتوي على جداول لختم القرآن من 1 إلى 5 مرات خلال 30 يوم
class RamadanKhatmaSchedule {
  /// إجمالي عدد صفحات المصحف
  static const int totalPages = 604;

  /// إجمالي عدد أجزاء القرآن
  static const int totalJuz = 30;

  /// قائمة السور مع عدد صفحاتها
  static const List<Map<String, dynamic>> surahs = [
    {'name': 'الفاتحة', 'pages': 1, 'startPage': 1},
    {'name': 'البقرة', 'pages': 48, 'startPage': 2},
    {'name': 'آل عمران', 'pages': 27, 'startPage': 50},
    {'name': 'النساء', 'pages': 29, 'startPage': 77},
    {'name': 'المائدة', 'pages': 22, 'startPage': 106},
    {'name': 'الأنعام', 'pages': 23, 'startPage': 128},
    {'name': 'الأعراف', 'pages': 24, 'startPage': 151},
    {'name': 'الأنفال', 'pages': 10, 'startPage': 177},
    {'name': 'التوبة', 'pages': 21, 'startPage': 187},
    {'name': 'يونس', 'pages': 14, 'startPage': 208},
    {'name': 'هود', 'pages': 14, 'startPage': 221},
    {'name': 'يوسف', 'pages': 12, 'startPage': 235},
    {'name': 'الرعد', 'pages': 6, 'startPage': 249},
    {'name': 'إبراهيم', 'pages': 6, 'startPage': 255},
    {'name': 'الحجر', 'pages': 5, 'startPage': 262},
    {'name': 'النحل', 'pages': 14, 'startPage': 267},
    {'name': 'الإسراء', 'pages': 12, 'startPage': 282},
    {'name': 'الكهف', 'pages': 11, 'startPage': 293},
    {'name': 'مريم', 'pages': 7, 'startPage': 305},
    {'name': 'طه', 'pages': 9, 'startPage': 312},
    {'name': 'الأنبياء', 'pages': 8, 'startPage': 322},
    {'name': 'الحج', 'pages': 10, 'startPage': 332},
    {'name': 'المؤمنون', 'pages': 9, 'startPage': 342},
    {'name': 'النور', 'pages': 9, 'startPage': 350},
    {'name': 'الفرقان', 'pages': 7, 'startPage': 359},
    {'name': 'الشعراء', 'pages': 11, 'startPage': 367},
    {'name': 'النمل', 'pages': 9, 'startPage': 377},
    {'name': 'القصص', 'pages': 11, 'startPage': 385},
    {'name': 'العنكبوت', 'pages': 8, 'startPage': 396},
    {'name': 'الروم', 'pages': 6, 'startPage': 404},
    {'name': 'لقمان', 'pages': 4, 'startPage': 411},
    {'name': 'السجدة', 'pages': 3, 'startPage': 415},
    {'name': 'الأحزاب', 'pages': 11, 'startPage': 418},
    {'name': 'سبأ', 'pages': 6, 'startPage': 428},
    {'name': 'فاطر', 'pages': 6, 'startPage': 434},
    {'name': 'يس', 'pages': 5, 'startPage': 440},
    {'name': 'الصافات', 'pages': 6, 'startPage': 446},
    {'name': 'ص', 'pages': 5, 'startPage': 453},
    {'name': 'الزمر', 'pages': 9, 'startPage': 458},
    {'name': 'غافر', 'pages': 9, 'startPage': 467},
    {'name': 'فصلت', 'pages': 6, 'startPage': 477},
    {'name': 'الشورى', 'pages': 6, 'startPage': 483},
    {'name': 'الزخرف', 'pages': 7, 'startPage': 489},
    {'name': 'الدخان', 'pages': 3, 'startPage': 496},
    {'name': 'الجاثية', 'pages': 4, 'startPage': 499},
    {'name': 'الأحقاف', 'pages': 4, 'startPage': 502},
    {'name': 'محمد', 'pages': 4, 'startPage': 507},
    {'name': 'الفتح', 'pages': 4, 'startPage': 511},
    {'name': 'الحجرات', 'pages': 3, 'startPage': 515},
    {'name': 'ق', 'pages': 3, 'startPage': 518},
    {'name': 'الذاريات', 'pages': 3, 'startPage': 520},
    {'name': 'الطور', 'pages': 2, 'startPage': 523},
    {'name': 'النجم', 'pages': 3, 'startPage': 526},
    {'name': 'القمر', 'pages': 3, 'startPage': 528},
    {'name': 'الرحمن', 'pages': 3, 'startPage': 531},
    {'name': 'الواقعة', 'pages': 3, 'startPage': 534},
    {'name': 'الحديد', 'pages': 4, 'startPage': 537},
    {'name': 'المجادلة', 'pages': 3, 'startPage': 542},
    {'name': 'الحشر', 'pages': 3, 'startPage': 545},
    {'name': 'الممتحنة', 'pages': 2, 'startPage': 549},
    {'name': 'الصف', 'pages': 2, 'startPage': 551},
    {'name': 'الجمعة', 'pages': 1, 'startPage': 553},
    {'name': 'المنافقون', 'pages': 2, 'startPage': 554},
    {'name': 'التغابن', 'pages': 2, 'startPage': 556},
    {'name': 'الطلاق', 'pages': 2, 'startPage': 558},
    {'name': 'التحريم', 'pages': 2, 'startPage': 560},
    {'name': 'الملك', 'pages': 2, 'startPage': 562},
    {'name': 'القلم', 'pages': 2, 'startPage': 564},
    {'name': 'الحاقة', 'pages': 2, 'startPage': 566},
    {'name': 'المعارج', 'pages': 2, 'startPage': 568},
    {'name': 'نوح', 'pages': 2, 'startPage': 570},
    {'name': 'الجن', 'pages': 2, 'startPage': 572},
    {'name': 'المزمل', 'pages': 1, 'startPage': 574},
    {'name': 'المدثر', 'pages': 2, 'startPage': 575},
    {'name': 'القيامة', 'pages': 1, 'startPage': 577},
    {'name': 'الإنسان', 'pages': 2, 'startPage': 578},
    {'name': 'المرسلات', 'pages': 2, 'startPage': 580},
    {'name': 'النبأ', 'pages': 1, 'startPage': 582},
    {'name': 'النازعات', 'pages': 2, 'startPage': 583},
    {'name': 'عبس', 'pages': 1, 'startPage': 585},
    {'name': 'التكوير', 'pages': 1, 'startPage': 586},
    {'name': 'الانفطار', 'pages': 1, 'startPage': 587},
    {'name': 'المطففين', 'pages': 1, 'startPage': 587},
    {'name': 'الانشقاق', 'pages': 1, 'startPage': 589},
    {'name': 'البروج', 'pages': 1, 'startPage': 590},
    {'name': 'الطارق', 'pages': 1, 'startPage': 591},
    {'name': 'الأعلى', 'pages': 1, 'startPage': 591},
    {'name': 'الغاشية', 'pages': 1, 'startPage': 592},
    {'name': 'الفجر', 'pages': 1, 'startPage': 593},
    {'name': 'البلد', 'pages': 1, 'startPage': 594},
    {'name': 'الشمس', 'pages': 1, 'startPage': 595},
    {'name': 'الليل', 'pages': 1, 'startPage': 595},
    {'name': 'الضحى', 'pages': 1, 'startPage': 596},
    {'name': 'الشرح', 'pages': 1, 'startPage': 596},
    {'name': 'التين', 'pages': 1, 'startPage': 597},
    {'name': 'العلق', 'pages': 1, 'startPage': 597},
    {'name': 'القدر', 'pages': 1, 'startPage': 598},
    {'name': 'البينة', 'pages': 1, 'startPage': 598},
    {'name': 'الزلزلة', 'pages': 1, 'startPage': 599},
    {'name': 'العاديات', 'pages': 1, 'startPage': 599},
    {'name': 'القارعة', 'pages': 1, 'startPage': 600},
    {'name': 'التكاثر', 'pages': 1, 'startPage': 600},
    {'name': 'العصر', 'pages': 1, 'startPage': 601},
    {'name': 'الهمزة', 'pages': 1, 'startPage': 601},
    {'name': 'الفيل', 'pages': 1, 'startPage': 601},
    {'name': 'قريش', 'pages': 1, 'startPage': 602},
    {'name': 'الماعون', 'pages': 1, 'startPage': 602},
    {'name': 'الكوثر', 'pages': 1, 'startPage': 602},
    {'name': 'الكافرون', 'pages': 1, 'startPage': 603},
    {'name': 'النصر', 'pages': 1, 'startPage': 603},
    {'name': 'المسد', 'pages': 1, 'startPage': 603},
    {'name': 'الإخلاص', 'pages': 1, 'startPage': 604},
    {'name': 'الفلق', 'pages': 1, 'startPage': 604},
    {'name': 'الناس', 'pages': 1, 'startPage': 604},
  ];

  /// إنشاء جدول الختمة اليومي
  /// [khatmaCount] عدد الختمات المطلوبة (1-5)
  /// يرجع قائمة من 30 عنصر، كل عنصر يحتوي على ورد اليوم
  static List<DailyWird> generateSchedule(int khatmaCount) {
    if (khatmaCount < 1) khatmaCount = 1;
    if (khatmaCount > 5) khatmaCount = 5;

    final int totalPagesNeeded = totalPages * khatmaCount;
    final int pagesPerDay = (totalPagesNeeded / 30).ceil();

    List<DailyWird> schedule = [];
    int currentPage = 1;

    for (int day = 1; day <= 30; day++) {
      int startPage = currentPage;
      int endPage = (currentPage + pagesPerDay - 1);

      // التأكد من عدم تجاوز إجمالي الصفحات المطلوبة
      if (endPage > totalPagesNeeded) {
        endPage = totalPagesNeeded;
      }

      // حساب الجزء الفعلي (1-30) مع مراعاة التكرار
      int startJuz = ((startPage - 1) ~/ 20) + 1;
      int endJuz = ((endPage - 1) ~/ 20) + 1;

      // إيجاد السور المشمولة في هذا اليوم
      List<String> surahsForDay = [];
      int tempPage = ((startPage - 1) % totalPages) + 1;
      int tempEndPage = ((endPage - 1) % totalPages) + 1;

      // إذا كانت نهاية الصفحة أقل من البداية، فهذا يعني أننا نبدأ ختمة جديدة
      if (tempEndPage < tempPage && khatmaCount > 1) {
        // أضف السور من البداية حتى نهاية المصحف
        for (int i = 0; i < surahs.length; i++) {
          int surahStart = surahs[i]['startPage'] as int;
          int surahEnd = surahStart + (surahs[i]['pages'] as int) - 1;
          if (surahStart >= tempPage || surahEnd >= tempPage) {
            surahsForDay.add(surahs[i]['name'] as String);
          }
        }
        // ثم أضف من بداية المصحف
        for (int i = 0; i < surahs.length; i++) {
          int surahEnd =
              (surahs[i]['startPage'] as int) + (surahs[i]['pages'] as int) - 1;
          if (surahEnd <= tempEndPage) {
            if (!surahsForDay.contains(surahs[i]['name'])) {
              surahsForDay.add(surahs[i]['name'] as String);
            }
          }
        }
      } else {
        for (int i = 0; i < surahs.length; i++) {
          int surahStart = surahs[i]['startPage'] as int;
          int surahEnd = surahStart + (surahs[i]['pages'] as int) - 1;

          // السورة تقع ضمن النطاق
          if ((surahStart >= tempPage && surahStart <= tempEndPage) ||
              (surahEnd >= tempPage && surahEnd <= tempEndPage) ||
              (surahStart <= tempPage && surahEnd >= tempEndPage)) {
            surahsForDay.add(surahs[i]['name'] as String);
          }
        }
      }

      schedule.add(
        DailyWird(
          day: day,
          startPage: ((startPage - 1) % totalPages) + 1,
          endPage: ((endPage - 1) % totalPages) + 1,
          pagesCount: pagesPerDay,
          startJuz: (startJuz - 1) % 30 + 1,
          endJuz: (endJuz - 1) % 30 + 1,
          surahs: surahsForDay,
        ),
      );

      currentPage = endPage + 1;
    }

    return schedule;
  }

  /// الحصول على ملخص الختمة
  static KhatmaSummary getSummary(int khatmaCount) {
    final int totalPagesNeeded = totalPages * khatmaCount;
    final int pagesPerDay = (totalPagesNeeded / 30).ceil();
    final int totalAjzaaNeeded = totalJuz * khatmaCount;
    final double ajzaaPerDay = totalAjzaaNeeded / 30;

    return KhatmaSummary(
      khatmaCount: khatmaCount,
      totalPages: totalPagesNeeded,
      pagesPerDay: pagesPerDay,
      ajzaaPerDay: ajzaaPerDay,
    );
  }
}

/// نموذج الورد اليومي
class DailyWird {
  final int day;
  final int startPage;
  final int endPage;
  final int pagesCount;
  final int startJuz;
  final int endJuz;
  final List<String> surahs;

  const DailyWird({
    required this.day,
    required this.startPage,
    required this.endPage,
    required this.pagesCount,
    required this.startJuz,
    required this.endJuz,
    required this.surahs,
  });

  String get pagesRange => '$startPage - $endPage';
  String get juzRange =>
      startJuz == endJuz ? 'الجزء $startJuz' : 'من الجزء $startJuz إلى $endJuz';
  String get surahsText => surahs.length > 3
      ? '${surahs.take(3).join("، ")} ...'
      : surahs.join("، ");
}

/// ملخص الختمة
class KhatmaSummary {
  final int khatmaCount;
  final int totalPages;
  final int pagesPerDay;
  final double ajzaaPerDay;

  const KhatmaSummary({
    required this.khatmaCount,
    required this.totalPages,
    required this.pagesPerDay,
    required this.ajzaaPerDay,
  });

  String get khatmaText =>
      khatmaCount == 1 ? 'ختمة واحدة' : '$khatmaCount ختمات';
}
