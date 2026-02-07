# تحسينات إشعارات الصلاة والأذان

## المشاكل التي تم حلها

### 1. إشعارات التنبيه قبل الأذان بـ 5 دقائق لا تعمل

**المشكلة:**
- إشعارات التنبيه قبل الأذان بـ 5 دقائق لم تكن تظهر بشكل موثوق

**الحل:**
- ✅ تحسين قناة `reminder_channel` لاستخدام `NotificationImportance.Max` بدلاً من `High`
- ✅ إضافة `criticalAlerts: true` لضمان الظهور على الأجهزة الحديثة
- ✅ التأكد من استخدام `allowWhileIdle: true` و `preciseAlarm: true` في جدولة الإشعارات

**الملفات المعدلة:**
- `lib/core/services/prayer_notification_services.dart` (السطور 524-532)

### 2. الأذان لا يعمل عندما تكون الشاشة مغلقة

**المشكلة:**
- الأذان كان يعمل فقط عندما يكون الهاتف نشطاً (الشاشة مفتوحة)
- عند إغلاق الشاشة، لم يكن الأذان يُشغل أو يُظهر الإشعار

**الحل:**
- ✅ تحسين `AthanForegroundService.wakeUpScreen()` لاستخدام طرق متعددة لإيقاظ الشاشة
- ✅ إضافة دعم `KeyguardManager` للتحقق من حالة القفل
- ✅ تحسين قناة الإشعارات لاستخدام `IMPORTANCE_MAX`
- ✅ إضافة `lockscreenVisibility = Notification.VISIBILITY_PUBLIC` للظهور على شاشة القفل
- ✅ إضافة `setBypassDnd(true)` لتجاوز وضع "عدم الإزعاج"

**الملفات المعدلة:**
- `android/app/src/main/kotlin/com/meshkatelhoda/pro/AthanForegroundService.kt` (السطور 84-134 و 273-289)

## كيفية عمل النظام

### 1. جدولة إشعارات التنبيه (5 دقائق قبل الأذان)

```dart
// في _scheduleWithAwesomeNotifications
if (settings.isPreAthanEnabled) {
  await _scheduleSingleNotification(
    notificationId++,
    prayer,
    prayerTime,
    language,
  );
}
```

- يتم جدولة الإشعار قبل 5 دقائق من وقت الصلاة
- يستخدم قناة `reminder_channel` مع صوت وإهتزاز
- يستخدم `NotificationImportance.Max` لضمان الظهور
- يستخدم `criticalAlerts: true` للأجهزة الحديثة

### 2. جدولة الأذان

```dart
// في _schedulePrayerTimeNotification
if (shouldPlayAthan) {
  await AthanAudioService().scheduleAthan(
    prayerId: id,
    prayerTime: prayerDateTime,
    prayerName: prayerName,
  );
}
```

- يستخدم `AlarmManager` الأصلي لجدولة الأذان
- عند حلول الوقت، يتم تشغيل `AthanBroadcastReceiver`
- `AthanBroadcastReceiver` يحصل على `WakeLock` فوراً لمنع النوم
- يبدأ `AthanForegroundService` لتشغيل الصوت

### 3. تشغيل الأذان عند إغلاق الشاشة

**التسلسل:**

1. **AlarmManager** يُطلق `AthanBroadcastReceiver` في الوقت المحدد
2. **AthanBroadcastReceiver**:
   - يحصل على `PARTIAL_WAKE_LOCK` فوراً (يمنع النوم)
   - يبدأ `AthanForegroundService`
3. **AthanForegroundService**:
   - يستلم `WakeLock` من `BroadcastReceiver`
   - يحصل على `SCREEN_BRIGHT_WAKE_LOCK` لإيقاظ الشاشة
   - يُنشئ إشعار `Foreground` مع `IMPORTANCE_MAX`
   - يُشغل صوت الأذان باستخدام `MediaPlayer`
   - يُظهر الإشعار على شاشة القفل

## الأذونات المطلوبة

تأكد من أن التطبيق لديه الأذونات التالية (موجودة في `AndroidManifest.xml`):

```xml
<!-- إيقاظ الجهاز -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>

<!-- جدولة الإنذارات الدقيقة -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

<!-- الخدمات الأمامية -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>

<!-- الظهور على شاشة القفل -->
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
<uses-permission android:name="android.permission.DISABLE_KEYGUARD"/>

<!-- تجاوز تحسين البطارية -->
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>
```

## اختبار التحسينات

### اختبار إشعارات التنبيه (5 دقائق قبل الأذان)

1. افتح التطبيق وفعّل "التنبيه قبل الأذان"
2. انتظر حتى قبل 5 دقائق من وقت الصلاة
3. يجب أن يظهر إشعار بعنوان "⏳ اقتربت الصلاة"
4. يجب أن يكون مع صوت وإهتزاز

### اختبار الأذان مع الشاشة المغلقة

1. افتح التطبيق وفعّل "الأذان"
2. **أغلق الشاشة تماماً** (اضغط زر الطاقة)
3. انتظر حتى وقت الصلاة
4. يجب أن:
   - تُضاء الشاشة تلقائياً
   - يظهر إشعار الأذان على شاشة القفل
   - يُشغل صوت الأذان
   - يمكنك إيقاف الأذان بالضغط على الإشعار

### اختبار مع وضع "عدم الإزعاج"

1. فعّل وضع "عدم الإزعاج" على الهاتف
2. انتظر حتى وقت الصلاة
3. يجب أن يُشغل الأذان رغم وضع "عدم الإزعاج" (بفضل `setBypassDnd(true)`)

## ملاحظات مهمة

### تحسين البطارية

- على بعض الأجهزة (خاصة Xiaomi, Huawei, Samsung)، قد يحتاج المستخدم إلى:
  1. إيقاف "تحسين البطارية" للتطبيق
  2. السماح بـ "التشغيل التلقائي"
  3. السماح بـ "التشغيل في الخلفية"

- يمكن للمستخدم فتح الإعدادات من التطبيق باستخدام:
  ```dart
  AthanAudioService().requestBatteryOptimizationExemption();
  ```

### الأذونات في وقت التشغيل

- على Android 12+، يحتاج المستخدم إلى منح إذن "جدولة الإنذارات الدقيقة"
- يمكن التحقق من الإذن باستخدام:
  ```dart
  bool canSchedule = await AthanAudioService().canScheduleExactAlarms();
  ```

## التوافق

- ✅ Android 6.0+ (API 23+)
- ✅ Android 12+ (مع دعم SCHEDULE_EXACT_ALARM)
- ✅ Android 14+ (مع دعم Foreground Service restrictions)

## الخلاصة

التحسينات تضمن:
1. ✅ إشعارات التنبيه قبل الأذان بـ 5 دقائق تعمل بشكل موثوق
2. ✅ الأذان يُشغل حتى عندما تكون الشاشة مغلقة
3. ✅ الإشعارات تظهر على شاشة القفل
4. ✅ لا تؤثر على إشعارات "ذكرني بالله" أو الإشعارات الأخرى
5. ✅ تعمل على جميع إصدارات Android الحديثة
