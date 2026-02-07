import 'package:flutter/material.dart';

// نموذج بيانات الصلاة
class PrayerTime {
  final TimeOfDay time;
  final String name;

  PrayerTime({required this.time, required this.name});
}

// نموذج بيانات الصلاة التالية
class NextPrayerInfo {
  final String prayerName;
  final String prayerTime;
  final String remainingTime;
  final bool isNightPrayer;

  NextPrayerInfo({
    required this.prayerName,
    required this.prayerTime,
    required this.remainingTime,
    required this.isNightPrayer,
  });
}
