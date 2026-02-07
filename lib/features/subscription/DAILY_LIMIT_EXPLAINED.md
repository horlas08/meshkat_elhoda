# 🔄 شرح نظام الليميت اليومي (Daily Limit System)

## 📍 المكان الرئيسي
الكود موجود في:
```
lib/features/assistant/data/datasources/assistant_local_data_source.dart
```

---

## 🎯 الآلية الكاملة

### 1️⃣ التخزين في SharedPreferences

يتم حفظ قيمتين:
```dart
static const String dailyQuestionCountKey = 'DAILY_QUESTION_COUNT';  // العدد الحالي
static const String lastQuestionDateKey = 'LAST_QUESTION_DATE';      // آخر تاريخ
```

---

### 2️⃣ التحقق التلقائي عند كل استعلام

```dart
@override
Future<int> getDailyQuestionCount() async {
  try {
    // 1. جلب آخر تاريخ تم حفظه
    final lastDate = await getLastQuestionDate();
    
    // 2. الحصول على تاريخ اليوم (بصيغة YYYY-MM-DD فقط)
    final today = DateTime.now().toIso8601String().split('T')[0];
    // مثال: "2025-11-26"

    // 3. المقارنة: هل اليوم يوم جديد؟
    if (lastDate != today) {
      // ✅ يوم جديد! إعادة تعيين العداد
      await resetDailyQuestionCount();
      return 0;
    }

    // ❌ نفس اليوم، إرجاع العداد الحالي
    return sharedPreferences.getInt(dailyQuestionCountKey) ?? 0;
  } catch (e) {
    throw const CacheException(message: 'Failed to get daily question count');
  }
}
```

**الفكرة الذكية:**
- كل مرة نطلب العداد، يتحقق تلقائياً: هل اليوم يوم جديد؟
- إذا كان يوم جديد → يُعيد العداد لـ 0 تلقائياً
- لا نحتاج لـ Cron Job أو Background Service!

---

### 3️⃣ زيادة العداد عند إرسال سؤال

```dart
@override
Future<void> incrementDailyQuestionCount() async {
  try {
    // 1. جلب العداد الحالي (سيتحقق تلقائياً من التاريخ)
    final currentCount = await getDailyQuestionCount();
    
    // 2. الحصول على تاريخ اليوم
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // 3. زيادة العداد بـ 1
    await sharedPreferences.setInt(dailyQuestionCountKey, currentCount + 1);
    
    // 4. حفظ تاريخ اليوم
    await sharedPreferences.setString(lastQuestionDateKey, today);
  } catch (e) {
    throw const CacheException(message: 'Failed to increment question count');
  }
}
```

---

### 4️⃣ إعادة التعيين اليدوية

```dart
@override
Future<void> resetDailyQuestionCount() async {
  try {
    // 1. إعادة العداد لـ 0
    await sharedPreferences.setInt(dailyQuestionCountKey, 0);
    
    // 2. حفظ تاريخ اليوم
    final today = DateTime.now().toIso8601String().split('T')[0];
    await sharedPreferences.setString(lastQuestionDateKey, today);
  } catch (e) {
    throw const CacheException(message: 'Failed to reset question count');
  }
}
```

---

## 🔄 سير العمل الكامل

### السيناريو 1: أول استخدام اليوم

```
1. المستخدم يفتح التطبيق الساعة 8 صباحاً (2025-11-26)
2. getDailyQuestionCount() يُستدعى
3. lastDate = null (أول مرة)
4. today = "2025-11-26"
5. lastDate != today → true
6. resetDailyQuestionCount() → count = 0
7. يعرض: "متبقي: 3 من 3"
```

### السيناريو 2: إرسال سؤال

```
1. المستخدم يرسل سؤال
2. AssistantBloc → incrementDailyQuestionCount()
3. currentCount = 0
4. newCount = 1
5. حفظ: count = 1, date = "2025-11-26"
6. يعرض: "متبقي: 2 من 3"
```

### السيناريو 3: اليوم التالي

```
1. المستخدم يفتح التطبيق الساعة 9 صباحاً (2025-11-27)
2. getDailyQuestionCount() يُستدعى
3. lastDate = "2025-11-26"
4. today = "2025-11-27"
5. lastDate != today → true ✅
6. resetDailyQuestionCount() → count = 0
7. يعرض: "متبقي: 3 من 3" (تم التجديد تلقائياً!)
```

---

## 🎨 أين يتم الاستدعاء؟

### في AssistantBloc

```dart
// عند تحميل المحادثة
Future<void> _onLoadChatHistory(...) async {
  final dailyCount = await localDataSource.getDailyQuestionCount();
  // ✅ هنا يتحقق تلقائياً من التاريخ
  emit(AssistantLoading(dailyQuestionCount: dailyCount));
}

// عند إرسال رسالة
Future<void> _onSendMessage(...) async {
  // زيادة العداد
  await localDataSource.incrementDailyQuestionCount();
  final newDailyCount = await localDataSource.getDailyQuestionCount();
  
  emit(AssistantSending(dailyQuestionCount: newDailyCount));
}
```

---

## 📊 البيانات المحفوظة في SharedPreferences

```json
{
  "DAILY_QUESTION_COUNT": 2,
  "LAST_QUESTION_DATE": "2025-11-26"
}
```

---

## ✅ المميزات

1. **تلقائي 100%**: لا يحتاج تدخل يدوي
2. **دقيق**: يعتمد على التاريخ فقط (YYYY-MM-DD)
3. **آمن**: يتحقق في كل مرة
4. **خفيف**: لا يحتاج Background Service
5. **موثوق**: يعمل حتى لو أغلق المستخدم التطبيق لأيام

---

## 🔍 مثال عملي

```dart
// اليوم: 2025-11-26
await getDailyQuestionCount();  // → 0 (أول مرة)
await incrementDailyQuestionCount();  // count = 1
await getDailyQuestionCount();  // → 1
await incrementDailyQuestionCount();  // count = 2
await getDailyQuestionCount();  // → 2

// --- المستخدم يغلق التطبيق ---
// --- اليوم التالي: 2025-11-27 ---

await getDailyQuestionCount();  // → 0 ✅ (تم التجديد تلقائياً!)
```

---

## 🎯 الخلاصة

**السؤال:** كيف يعرف التطبيق أن اليوم انتهى؟

**الجواب:** 
- كل مرة تطلب العداد، يقارن التاريخ المحفوظ مع تاريخ اليوم
- إذا اختلف → يعيد العداد لـ 0 تلقائياً
- **لا يحتاج Timer أو Background Task!**

---

## 🔧 للاختبار

إذا أردت اختبار التجديد اليومي بدون انتظار:

```dart
// في assistant_local_data_source.dart
// غيّر السطر 64 مؤقتاً:
final today = DateTime.now().toIso8601String().split('T')[0];

// إلى:
final today = DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0];

// ثم أعد تشغيل التطبيق → سيعتبره يوم جديد!
```

---

**الكود ذكي جداً! 🧠**
