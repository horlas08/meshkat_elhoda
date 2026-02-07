import 'package:meshkat_elhoda/features/prayer_times/domain/entities/prayer_times_entity.dart';

class PrayerTimesModel extends PrayerTimesEntity {
  const PrayerTimesModel({
    required super.fajr,
    required super.sunrise,
    required super.dhuhr,
    required super.asr,
    required super.maghrib,
    required super.isha,
    required super.dateInfo,
    required super.timezone,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final timings = data['timings'] as Map<String, dynamic>;
    final date = data['date'] as Map<String, dynamic>;

    return PrayerTimesModel(
      fajr: _cleanTime(timings['Fajr'] as String),
      sunrise: _cleanTime(timings['Sunrise'] as String),
      dhuhr: _cleanTime(timings['Dhuhr'] as String),
      asr: _cleanTime(timings['Asr'] as String),
      maghrib: _cleanTime(timings['Maghrib'] as String),
      isha: _cleanTime(timings['Isha'] as String),
      dateInfo: DateInfoModel.fromJson(date),
      timezone: data['meta']?['timezone'] as String? ?? 'UTC',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'timings': {
          'Fajr': fajr,
          'Sunrise': sunrise,
          'Dhuhr': dhuhr,
          'Asr': asr,
          'Maghrib': maghrib,
          'Isha': isha,
        },
        'date': (dateInfo as DateInfoModel).toJson(),
        'meta': {
          'timezone': timezone,
        },
      },
    };
  }

  static String _cleanTime(String time) {
    // Remove timezone info from time (e.g., "05:30 (EET)" -> "05:30")
    return time.split(' ').first;
  }
}

class DateInfoModel extends DateInfo {
  const DateInfoModel({
    required super.gregorian,
    required super.hijri,
  });

  factory DateInfoModel.fromJson(Map<String, dynamic> json) {
    return DateInfoModel(
      gregorian: GregorianDateModel.fromJson(json['gregorian']),
      hijri: HijriDateModel.fromJson(json['hijri']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gregorian': (gregorian as GregorianDateModel).toJson(),
      'hijri': (hijri as HijriDateModel).toJson(),
    };
  }
}

class GregorianDateModel extends GregorianDate {
  const GregorianDateModel({
    required super.date,
    required super.day,
    required super.month,
    required super.year,
    required super.weekday,
  });

  factory GregorianDateModel.fromJson(Map<String, dynamic> json) {
    return GregorianDateModel(
      date: json['date'] as String,
      day: json['day'] as String,
      month: json['month']['en'] as String,
      year: json['year'] as String,
      weekday: json['weekday']['en'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'month': {'en': month},
      'year': year,
      'weekday': {'en': weekday},
    };
  }
}

class HijriDateModel extends HijriDate {
  const HijriDateModel({
    required super.date,
    required super.day,
    required super.month,
    required super.year,
    required super.weekday,
  });

  factory HijriDateModel.fromJson(Map<String, dynamic> json) {
    return HijriDateModel(
      date: json['date'] as String,
      day: json['day'] as String,
      month: json['month']['ar'] as String,
      year: json['year'] as String,
      weekday: json['weekday']['ar'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'month': {'ar': month},
      'year': year,
      'weekday': {'ar': weekday},
    };
  }
}
