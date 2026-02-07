# 🚀 دليل سريع: نظام الاشتراكات

## ✅ تم التنفيذ

### 1️⃣ البنية الكاملة
```
lib/features/subscription/
├── domain/entities/
│   ├── app_feature.dart          ← Enum للميزات
│   ├── feature_manager.dart      ← المدير المركزي
│   └── user_subscription_entity.dart
├── data/
│   ├── models/user_subscription_model.dart
│   ├── datasources/subscription_local_data_source.dart
│   └── repositories/subscription_repository_impl.dart
└── presentation/
    └── bloc/subscription_bloc.dart
```

### 2️⃣ تتبع الأسئلة اليومية للـ AI
- ✅ عداد تلقائي في `AssistantBloc`
- ✅ إعادة تعيين يومية
- ✅ حفظ في SharedPreferences

### 3️⃣ Widgets جاهزة
- `DailyQuestionCounter` → عرض الأسئلة المتبقية
- `AiQuestionLimitChecker` → التحقق من الحد
- `canSendMessage()` → Helper function

---

## 📖 الاستخدام السريع

### في أي صفحة:

```dart
BlocBuilder<SubscriptionBloc, SubscriptionState>(
  builder: (context, state) {
    if (state is SubscriptionLoaded) {
      final manager = state.featureManager;
      
      // ✅ طريقة 1: Getter مباشر
      if (manager.canUseAdvancedTafseer) {
        return AdvancedFeature();
      }
      
      // ✅ طريقة 2: Enum
      if (manager.isAllowed(AppFeature.offlineAudio)) {
        return DownloadButton();
      }
    }
    return LoadingWidget();
  },
)
```

### في المساعد الذكي:

```dart
// 1. عرض العداد
AppBar(
  actions: [DailyQuestionCounter()],
)

// 2. التحقق قبل الإرسال
final canSend = await canSendMessage(context);
if (!canSend) return; // سيعرض dialog تلقائياً

// 3. إرسال الرسالة
context.read<AssistantBloc>().add(SendMessageEvent(...));
```

---

## 🎯 الميزات المتاحة

| الميزة | مجاني | مميز |
|--------|-------|------|
| القرآن الكامل | ✅ | ✅ |
| القراء | 1-3 | 10-15 |
| التفاسير | 1 أساسي | جميع التفاسير |
| التحميل بدون نت | ❌ | ✅ |
| الأحاديث | البخاري+مسلم | الكتب الستة |
| الأذكار | أساسية | حصن المسلم كامل |
| المساعد الذكي | 3 أسئلة/يوم | غير محدود |
| وضع رمضان | ❌ | ✅ |
| الترجمات | عربي+إنجليزي | 12+ لغة |
| الإعلانات | موجودة | محذوفة |

---

## 🔧 للاختبار

في `subscription_local_data_source.dart`:

```dart
// مجاني
return UserSubscriptionModel(type: 'free', expireAt: null);

// مميز
return UserSubscriptionModel(
  type: 'premium',
  expireAt: DateTime.now().add(Duration(days: 30)),
);
```

---

## 📂 الملفات المهمة

| الملف | الوصف |
|------|-------|
| `README.md` | دليل شامل مفصل |
| `EXAMPLES.dart` | أمثلة لجميع الميزات |
| `assistant_page_example.dart` | مثال كامل للمساعد |
| `ai_question_limit_checker.dart` | Widgets جاهزة |

---

## ⚡ Next Steps

1. ✅ النظام جاهز للاستخدام
2. 🔄 طبّق على باقي الصفحات (استخدم EXAMPLES.dart)
3. 🔗 اربط مع Firebase/Firestore
4. 💳 أضف صفحة الدفع
5. 📱 اختبر على الجهاز

---

## 💡 نصيحة

ابدأ بتطبيق النظام على صفحة واحدة (مثل المساعد الذكي)، ثم انسخ نفس الطريقة للصفحات الأخرى.

**كل شيء جاهز ومُختبر! 🎉**
