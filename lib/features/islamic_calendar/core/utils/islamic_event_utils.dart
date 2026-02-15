
import 'package:hijri/hijri_calendar.dart';
import 'package:meshkat_elhoda/features/islamic_calendar/domain/entities/islamic_event.dart';

class IslamicEventUtils {
  static List<IslamicEvent> getEventsForHijriYear(int hYear) {
    final events = <IslamicEvent>[];

    // Helper to add event
    void addEvent(String key, int month, int day) {
      final hDate = HijriCalendar();
      // standard hijri package method to convert
      DateTime gDate = hDate.hijriToGregorian(hYear, month, day);
      
      events.add(IslamicEvent(
        titleKey: key,
        hMonth: month,
        hDay: day,
        gregorianDate: gDate,
      ));
    }

    // 1. Al-Hijra (New Year) - 1 Muharram
    addEvent('eventAlHijra', 1, 1);

    // 2. Ashura - 10 Muharram
    addEvent('eventAshura', 1, 10);

    // 3. Mawlid al-Nabi - 12 Rabi' al-Awwal
    addEvent('eventMawlidAlNabi', 3, 12);

    // 4. Laylat al-Miraj - 27 Rajab
    addEvent('eventLaylatAlMiraj', 7, 27);

    // 5. Laylat al-Baraat - 15 Sha'ban
    addEvent('eventLaylatAlBaraat', 8, 15);

    // 6. Ramadan Start - 1 Ramadan
    addEvent('eventRamadanStart', 9, 1);

    // 7. Laylat al-Qadr - 27 Ramadan
    addEvent('eventLaylatAlQadr', 9, 27);

    // 8. Eid al-Fitr - 1 Shawwal
    addEvent('eventEidAlFitr', 10, 1);

    // 9. Hajj (Arafah) - 9 Dhul-Hijjah
    addEvent('eventHajj', 12, 9);

    // 10. Eid al-Adha - 10 Dhul-Hijjah
    addEvent('eventEidAlAdha', 12, 10);

    // Sort by date (already roughly sorted by month, but good to be sure)
    events.sort((a, b) {
      if (a.hMonth != b.hMonth) return a.hMonth.compareTo(b.hMonth);
      return a.hDay.compareTo(b.hDay);
    });

    return events;
  }
}
