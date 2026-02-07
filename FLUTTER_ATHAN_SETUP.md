# 🔔 دليل إعداد الأذان بـ Flutter

## نظرة عامة

تم تحويل نظام الأذان من native code (Kotlin/Swift) إلى Flutter فقط لضمان قبول التطبيق في App Store.

## الآلية الجديدة (الحل الهجين)

### كيف يعمل:

1. **إشعار مجدول مع صوت قصير (30 ثانية)**
   - يعمل دائماً حتى لو التطبيق مغلق تماماً (terminated)
   - الصوت محدود بـ 30 ثانية على iOS (قيود Apple)

2. **تشغيل الأذان كاملاً**
   - يعمل إذا كان التطبيق في الخلفية (background)
   - لا يعمل إذا التطبيق مغلق تماماً (terminated)

---

## 📁 هيكل ملفات الصوت

### الملفات الكاملة (الموجودة):
```
assets/athan/
├── ali_almula_fajr.mp3      (الأذان الكامل - الفجر)
├── ali_almula_regular.mp3   (الأذان الكامل - العادي)
├── nasr_tobar_fajr.mp3
├── nasr_tobar_regular.mp3
├── srehi_fajr.mp3
└── srehi_regular.mp3
```

### الملفات القصيرة المطلوبة (يجب إنشاؤها):
```
android/app/src/main/res/raw/
├── ali_almula_fajr_short.mp3      (أول 30 ثانية)
├── ali_almula_regular_short.mp3
├── nasr_tobar_fajr_short.mp3
├── nasr_tobar_regular_short.mp3
├── srehi_fajr_short.mp3
└── srehi_regular_short.mp3

ios/Runner/Sounds/               (نفس الملفات)
```

---

## 🛠️ كيفية إنشاء ملفات الصوت القصيرة

### الطريقة 1: باستخدام FFmpeg (موصى بها)

```bash
# انتقل إلى مجلد الأصوات
cd assets/athan

# اقطع أول 30 ثانية من كل ملف
ffmpeg -i ali_almula_fajr.mp3 -t 30 -acodec copy ../short/ali_almula_fajr_short.mp3
ffmpeg -i ali_almula_regular.mp3 -t 30 -acodec copy ../short/ali_almula_regular_short.mp3
ffmpeg -i nasr_tobar_fajr.mp3 -t 30 -acodec copy ../short/nasr_tobar_fajr_short.mp3
ffmpeg -i nasr_tobar_regular.mp3 -t 30 -acodec copy ../short/nasr_tobar_regular_short.mp3
ffmpeg -i srehi_fajr.mp3 -t 30 -acodec copy ../short/srehi_fajr_short.mp3
ffmpeg -i srehi_regular.mp3 -t 30 -acodec copy ../short/srehi_regular_short.mp3
```

### الطريقة 2: باستخدام أداة online

1. استخدم موقع مثل [mp3cut.net](https://mp3cut.net)
2. ارفع كل ملف
3. اقطع أول 30 ثانية
4. حمّل الملف المقطوع

---

## 📱 إعداد iOS

### 1. إضافة أصوات الإشعارات:

1. افتح Xcode
2. انقر بزر الماوس الأيمن على Runner > Add Files to "Runner"
3. أنشئ مجلد "Sounds"
4. أضف ملفات الصوت القصيرة (بصيغة `.caf` أو `.wav` لأفضل توافق)

### 2. إضافة أذونات في Info.plist:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 3. تفعيل Critical Alerts (اختياري):

للحصول على إذن Critical Alerts، يجب:
1. التقدم بطلب لـ Apple عبر https://developer.apple.com/contact/request/notifications-critical-alerts-entitlement/
2. إضافة الـ entitlement بعد الموافقة

---

## 🤖 إعداد Android

### 1. نسخ ملفات الصوت القصيرة:

انسخ الملفات إلى:
```
android/app/src/main/res/raw/
```

### 2. التأكد من الأذونات في AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

---

## 🧪 اختبار النظام

### 1. اختبار التشغيل الفوري:

```dart
import 'package:meshkat_elhoda/core/services/flutter_athan_service.dart';

// تشغيل الأذان فوراً
await FlutterAthanService().playAthanForPrayer('Fajr');

// إيقاف الأذان
await FlutterAthanService().stopAthan();
```

### 2. اختبار جدولة الأذان:

```dart
// جدولة أذان بعد دقيقة
final testTime = DateTime.now().add(Duration(minutes: 1));
await FlutterAthanService().scheduleAthan(
  prayerId: 99,
  prayerTime: testTime,
  prayerName: 'Dhuhr',
);
```

---

## 📝 ملاحظات هامة

1. **iOS - صوت الإشعار**: محدود بـ 30 ثانية كحد أقصى
2. **iOS - التطبيق المغلق**: الأذان الكامل لن يعمل إذا أغلق المستخدم التطبيق
3. **Android**: يعمل بشكل أفضل، لكن بعض الأجهزة قد تقتل التطبيق
4. **Battery Optimization**: أنصح المستخدمين بتعطيل توفير الطاقة للتطبيق

---

## 🔄 الترقية من الكود القديم

إذا كنت تستخدم الكود القديم (native)، لا حاجة لتغيير أي شيء في باقي التطبيق.
الواجهات تبقى كما هي:

```dart
// هذا لا يزال يعمل:
AthanAudioService().scheduleAthan(...);
AthanAudioService().playAthanForPrayer('Fajr');
AthanAudioService().stopAthan();
```

---

## ⚠️ حذف الكود القديم (اختياري)

بعد التأكد من عمل النظام الجديد، يمكنك حذف:

### Android:
- `android/app/src/main/kotlin/com/meshkatelhoda/pro/AthanAlarmManager.kt`
- `android/app/src/main/kotlin/com/meshkatelhoda/pro/AthanBroadcastReceiver.kt`
- `android/app/src/main/kotlin/com/meshkatelhoda/pro/AthanForegroundService.kt`
- `android/app/src/main/kotlin/com/meshkatelhoda/pro/AthanNotificationService.kt`

### iOS:
- `ios/Runner/AthanAudioPlayer.swift`
- `ios/Runner/AthanManager.swift`
- `ios/Runner/AthanMethodChannel.swift`
- `ios/AthanNotificationService/` (المجلد بالكامل)

**تنبيه**: لا تحذف هذه الملفات حتى تتأكد من قبول التطبيق في المتاجر!
