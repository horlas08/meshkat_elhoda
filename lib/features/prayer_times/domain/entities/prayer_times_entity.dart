import 'package:equatable/equatable.dart';

enum CalendarType { hijri, gregorian }

class PrayerTimesEntity extends Equatable {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final DateInfo dateInfo;
  final String timezone;

  const PrayerTimesEntity({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.dateInfo,
    required this.timezone,
  });

  @override
  List<Object?> get props => [
        fajr,
        sunrise,
        dhuhr,
        asr,
        maghrib,
        isha,
        dateInfo,
        timezone,
      ];
}

class DateInfo extends Equatable {
  final GregorianDate gregorian;
  final HijriDate hijri;

  const DateInfo({
    required this.gregorian,
    required this.hijri,
  });

  @override
  List<Object?> get props => [gregorian, hijri];
}

class GregorianDate extends Equatable {
  final String date;
  final String day;
  final String month;
  final String year;
  final String weekday;

  const GregorianDate({
    required this.date,
    required this.day,
    required this.month,
    required this.year,
    required this.weekday,
  });

  @override
  List<Object?> get props => [date, day, month, year, weekday];
}

class HijriDate extends Equatable {
  final String date;
  final String day;
  final String month;
  final String year;
  final String weekday;

  const HijriDate({
    required this.date,
    required this.day,
    required this.month,
    required this.year,
    required this.weekday,
  });

  @override
  List<Object?> get props => [date, day, month, year, weekday];
}
