import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class OccasionNotificationService {
  static final OccasionNotificationService _instance =
      OccasionNotificationService._internal();
  factory OccasionNotificationService() => _instance;
  OccasionNotificationService._internal();

  Future<void> initialize() async {
    // Ensure channel exists
    await AwesomeNotifications().setChannel(
      NotificationChannel(
        channelKey: 'occasions_channel',
        channelName: 'Islamic Occasions',
        channelDescription: 'Reminders for Friday, White Days, and Islamic Events',
        defaultColor: const Color(0xFFD4AF37),
        ledColor: const Color(0xFFD4AF37),
        importance: NotificationImportance.High,
        playSound: true,
      ),
    );
  }

  /// Checks if there is an occasion today and schedules a notification if not already sent.
  /// Should be called daily (e.g. from background task).
  Future<void> checkAndNotify() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month}-${today.day}";

    // Check if already notified today for general occasions
    final lastNotified = prefs.getString('last_occasion_notification_date');
    if (lastNotified == dateKey) {
      debugPrint("OccasionNotification: Already verified today.");
      return;
    }

    final lang = prefs.getString('language') ?? 'ar';
    final isAr = lang == 'ar';

    final hijri = HijriCalendar.now();
    
    // 1. Friday Check (Surah Al-Kahf)
    if (today.weekday == DateTime.friday) {
      await _sendNotification(
        id: 100,
        title: isAr ? "جمعة مباركة" : "Jumu'ah Mubarak",
        body: isAr 
            ? "لا تنس قراءة سورة الكهف والإكثار من الصلاة على النبي ﷺ" 
            : "Don't forget to read Surah Al-Kahf and send Salawat upon the Prophet ﷺ",
      );
    }

    // 2. White Days (13, 14, 15)
    if ([13, 14, 15].contains(hijri.hDay)) {
       await _sendNotification(
        id: 200 + hijri.hDay,
        title: isAr ? "الأيام البيض" : "The White Days",
        body: isAr
            ? "تذكير: صيام الأيام البيض (${hijri.hDay} من الشهر الهجري)"
            : "Reminder: Fasting the White Days (${hijri.hDay}th of Hijri month).",
      );
    }

    // 3. Ramadan Start (approx check, typically requires sighting, but we can remind on 1st/Last)
    if (hijri.hMonth == 9 && hijri.hDay == 1) {
       await _sendNotification(
        id: 300,
        title: isAr ? "رمضان كريم" : "Ramadan Kareem",
        body: isAr
            ? "مبارك عليكم الشهر، تقبل الله منا ومنكم الصيام والقيام"
            : "Blessed month of Ramadan has started. May Allah accept our fasting.",
      );
    }

    // 4. Day of Arafah (9 Dhul-Hijjah)
    if (hijri.hMonth == 12 && hijri.hDay == 9) {
       await _sendNotification(
        id: 400,
        title: isAr ? "يوم عرفة" : "Day of Arafah",
        body: isAr
            ? "صيام يوم عرفة يكفر السنة الماضية والباقية"
            : "Fasting on the Day of Arafah expiates the sins of the previous and coming year.",
      );
    }

    // 5. Ashura (10 Muharram)
    if (hijri.hMonth == 1 && hijri.hDay == 10) {
       await _sendNotification(
        id: 500,
        title: isAr ? "يوم عاشوراء" : "Day of Ashura",
        body: isAr
            ? "تذكير بصيام يوم عاشوراء"
            : "Reminder to fast for the Day of Ashura.",
      );
    }
    
    // Mark checked for today
    await prefs.setString('last_occasion_notification_date', dateKey);
  }

  Future<void> _sendNotification({required int id, required String title, required String body}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'occasions_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
