# دليل استخدام نظام إدارة الاشتراكات والميزات

## نظرة عامة

تم تطبيق نظام شامل لإدارة الميزات المجانية والمدفوعة في التطبيق باستخدام Clean Architecture.

---

## 🏗️ البنية

```
lib/features/subscription/
├── data/
│   ├── datasources/
│   │   └── subscription_local_data_source.dart
│   ├── models/
│   │   └── user_subscription_model.dart
│   └── repositories/
│       └── subscription_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── app_feature.dart
│   │   ├── feature_manager.dart
│   │   └── user_subscription_entity.dart
│   └── repositories/
│       └── subscription_repository.dart
└── presentation/
    ├── bloc/
    │   ├── subscription_bloc.dart
    │   ├── subscription_event.dart
    │   └── subscription_state.dart
    └── pages/
        └── subscription_example_page.dart
```

---

## 📋 الميزات المتاحة

### الميزات المجانية (Free):
- ✅ القرآن الكامل مع 1-3 قراء
- ✅ تفسير واحد أساسي
- ✅ مواقيت الصلاة والقبلة
- ✅ أذكار أساسية
- ✅ المساعد الذكي: **3 أسئلة يومياً**
- ⚠️ يحتوي على إعلانات

### الميزات المدفوعة (Premium):
- 🌟 جميع التفاسير
- 🌟 قراء متعددين (10-15)
- 🌟 تحميل السور للاستماع بدون إنترنت
- 🌟 ترجمات متعددة
- 🌟 وضع رمضان
- 🌟 المساعد الذكي: **أسئلة غير محدودة**
- 🌟 إزالة الإعلانات

---

## 🔧 كيفية الاستخدام

### 1. في أي صفحة - التحقق من الميزة

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/features/subscription/domain/entities/app_feature.dart';

class MyFeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoaded) {
          final manager = state.featureManager;
          
          // طريقة 1: استخدام Getter مباشر
          if (manager.canUseAdvancedTafseer) {
            return AdvancedTafseerWidget();
          } else {
            return LockedFeatureWidget(
              onUpgrade: () => _showUpgradeDialog(context),
            );
          }
        }
        return QuranLottieLoading();
      },
    );
  }
}
```

### 2. استخدام Enum للميزات

```dart
// طريقة 2: استخدام Enum (أفضل للديناميكية)
if (manager.isAllowed(AppFeature.offlineAudio)) {
  // السماح بالتحميل
  downloadAudio();
} else {
  // عرض رسالة الترقية
  showUpgradeDialog();
}
```

### 3. في المساعد الذكي - التحقق من الحد اليومي

```dart
import 'package:meshkat_elhoda/features/assistant/presentation/widgets/ai_question_limit_checker.dart';

// في صفحة المساعد الذكي
class AssistantPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المساعد الذكي'),
        actions: [
          // عرض عداد الأسئلة المتبقية
          DailyQuestionCounter(),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: MessagesList()),
          
          // التحقق من الحد قبل إظهار حقل الإدخال
          AiQuestionLimitChecker(
            onLimitReached: () {
              // الانتقال لصفحة الاشتراك
              Navigator.pushNamed(context, '/subscription');
            },
            child: MessageInputField(),
          ),
        ],
      ),
    );
  }
}
```

### 4. قبل إرسال رسالة للمساعد

```dart
import 'package:meshkat_elhoda/features/assistant/presentation/widgets/ai_question_limit_checker.dart';

Future<void> sendMessage(BuildContext context, String message) async {
  // التحقق من الصلاحية
  final canSend = await canSendMessage(context);
  
  if (!canSend) {
    // سيتم عرض dialog تلقائياً
    return;
  }
  
  // إرسال الرسالة
  context.read<AssistantBloc>().add(
    SendMessageEvent(
      chatId: currentChatId,
      message: message,
      model: selectedModel,
    ),
  );
}
```

---

## 🎨 Widgets جاهزة للاستخدام

### 1. DailyQuestionCounter
يعرض عداد الأسئلة المتبقية للمستخدمين المجانيين

```dart
AppBar(
  actions: [
    DailyQuestionCounter(), // يختفي تلقائياً للمستخدمين المميزين
  ],
)
```

### 2. AiQuestionLimitChecker
يتحقق من الحد ويعرض رسالة إذا تم الوصول للحد الأقصى

```dart
AiQuestionLimitChecker(
  onLimitReached: () {
    // Action عند الوصول للحد
  },
  child: YourInputWidget(),
)
```

---

## 🔄 تغيير نوع الاشتراك (للاختبار)

في الملف:
`lib/features/subscription/data/datasources/subscription_local_data_source.dart`

```dart
@override
Future<UserSubscriptionModel> getSubscription() async {
  await Future.delayed(const Duration(milliseconds: 500));
  
  // للاختبار كمستخدم مجاني
  return UserSubscriptionModel(
    type: 'free', 
    expireAt: null,
  );
  
  // للاختبار كمستخدم مميز
  // return UserSubscriptionModel(
  //   type: 'premium',
  //   expireAt: DateTime.now().add(Duration(days: 30)),
  // );
}
```

---

## 📊 تتبع الأسئلة اليومية

النظام يتتبع تلقائياً:
- ✅ عدد الأسئلة المرسلة يومياً
- ✅ إعادة تعيين العداد تلقائياً كل يوم
- ✅ حفظ البيانات في SharedPreferences

---

## 🎯 إضافة ميزة جديدة

### 1. أضف الميزة في Enum

```dart
// lib/features/subscription/domain/entities/app_feature.dart
enum AppFeature {
  advancedTranslations,
  advancedTafseer,
  offlineAudio,
  multipleReaders,
  aiUnlimited,
  ramadanMode,
  noAds,
  newFeature, // ← ميزة جديدة
}
```

### 2. أضف Getter في FeatureManager

```dart
// lib/features/subscription/domain/entities/feature_manager.dart
bool get canUseNewFeature => _isPremium;
```

### 3. أضف Case في isAllowed

```dart
bool isAllowed(AppFeature feature) {
  switch (feature) {
    // ... existing cases
    case AppFeature.newFeature:
      return canUseNewFeature;
  }
}
```

---

## 🚀 التكامل مع الصفحات الموجودة

### مثال: صفحة القرآن

```dart
class QuranPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is! SubscriptionLoaded) return LoadingWidget();
        
        final manager = state.featureManager;
        
        return Column(
          children: [
            // عرض القراء المتاحين
            ReciterSelector(
              reciters: manager.canUseMultipleReaders 
                ? allReciters 
                : freeReciters,
            ),
            
            // زر التحميل
            if (manager.canUseOfflineAudio)
              DownloadButton()
            else
              LockedButton(
                text: 'التحميل (مميز فقط)',
                onTap: () => showUpgradeDialog(context),
              ),
          ],
        );
      },
    );
  }
}
```

---

## 📱 الربط مع Firebase (مستقبلاً)

عندما تريد الربط مع Firestore:

1. أنشئ `SubscriptionRemoteDataSource`
2. عدّل `SubscriptionRepositoryImpl` لاستخدام Remote + Local
3. البنية جاهزة - فقط استبدل Mock بـ Real data

```dart
// مثال مستقبلي
class SubscriptionRemoteDataSourceImpl {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  
  Future<UserSubscriptionModel> getSubscription() async {
    final userId = auth.currentUser?.uid;
    final doc = await firestore
      .collection('users')
      .doc(userId)
      .get();
    
    return UserSubscriptionModel.fromJson(
      doc.data()?['subscription'] ?? {},
    );
  }
}
```

---

## ✅ Checklist للتطبيق

- [x] نظام الاشتراكات الأساسي
- [x] FeatureManager مع جميع الميزات
- [x] تتبع الأسئلة اليومية للـ AI
- [x] Widgets جاهزة للاستخدام
- [x] Dependency Injection في service_locator
- [ ] ربط مع Firebase/Firestore
- [ ] صفحة الاشتراك والدفع
- [ ] إزالة الإعلانات للمستخدمين المميزين
- [ ] تطبيق القيود على باقي الصفحات

---

## 🎓 ملاحظات مهمة

1. **الأمان**: حالياً البيانات محلية - يجب التحقق من الاشتراك من السيرفر
2. **التخزين المؤقت**: النظام يستخدم SharedPreferences للتخزين المحلي
3. **الأداء**: FeatureManager خفيف جداً - لا يؤثر على الأداء
4. **التوسع**: البنية قابلة للتوسع بسهولة لإضافة ميزات جديدة

---

## 📞 الدعم

للأسئلة أو المشاكل، راجع الكود في:
- `lib/features/subscription/`
- `lib/features/assistant/presentation/widgets/ai_question_limit_checker.dart`
