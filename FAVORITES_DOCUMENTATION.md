# 📚 Favorites Feature - التوثيق الكامل

## 📖 نظرة عامة
مودول **Favorites** متكامل يتيح للمستخدمين حفظ واسترجاع العناصر المفضلة لديهم من Firestore مع تحديثات فورية في الوقت الفعلي.

---

## 🏗️ البنية المعمارية (Clean Architecture)

```
features/favorites/
├── domain/                          # طبقة المنطق التجاري
│   ├── entities/
│   │   └── favorite_item.dart       # نموذج البيانات الأساسي
│   └── repositories/
│       └── favorites_repository.dart # العقد (Contract)
│
├── data/                            # طبقة الوصول للبيانات
│   ├── models/
│   │   └── favorite_item_model.dart # نموذج التحويل (JSON ↔ Entity)
│   ├── datasources/
│   │   └── favorites_remote_data_source.dart # Firestore
│   └── repositories/
│       └── favorites_repository_impl.dart # التنفيذ
│
└── presentation/                    # طبقة الواجهة
    ├── bloc/
    │   ├── favorites_bloc.dart      # إدارة الحالة
    │   ├── favorites_event.dart     # الأحداث
    │   └── favorites_state.dart     # الحالات
    └── screens/
        └── favorites_screen.dart    # مثال الاستخدام
```

---

## 🔑 المفاهيم الأساسية

### 1️⃣ FavoriteItem (Entity)
```dart
class FavoriteItem extends Equatable {
  final String id;                 // معرّف فريد
  final String title;              // العنوان
  final String? description;       // الوصف (اختياري)
  final String? category;          // الفئة (قرآن، حديث، إلخ)
  final DateTime createdAt;        // تاريخ الإنشاء
  final DateTime? updatedAt;       // تاريخ التحديث
}
```

### 2️⃣ FavoritesRepository (العقد)
```dart
abstract class FavoritesRepository {
  /// الحصول على المفضلات كـ Stream (تحديثات فورية)
  Stream<List<FavoriteItem>> getFavorites(String userId);
  
  /// إضافة عنصر
  Future<void> addFavorite(String userId, FavoriteItem item);
  
  /// حذف عنصر
  Future<void> removeFavorite(String userId, String itemId);
  
  /// التحقق من وجود عنصر
  Future<bool> isFavorite(String userId, String itemId);
  
  /// حذف الكل
  Future<void> clearAllFavorites(String userId);
}
```

### 3️⃣ Firestore Structure
```
users/{userId}/favorites/
├── surah_1
│   ├── id: "surah_1"
│   ├── title: "سورة الفاتحة"
│   ├── description: "فاتحة الكتاب"
│   ├── category: "قرآن"
│   ├── createdAt: "2025-11-21T10:30:00Z"
│   └── updatedAt: null
├── surah_2
│   └── ...
└── hadith_5
    └── ...
```

---

## 🎯 استخدام الـ Bloc

### أ) تحميل المفضلات
```dart
// إصدار الحدث
context.read<FavoritesBloc>().add(
  LoadFavorites(userId: firebaseUser.uid),
);

// الاستماع للحالة
BlocListener<FavoritesBloc, FavoritesState>(
  listener: (context, state) {
    if (state is FavoritesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: ...,
)
```

### ب) إضافة عنصر للمفضلات
```dart
context.read<FavoritesBloc>().add(
  AddFavorite(
    userId: firebaseUser.uid,
    item: FavoriteItem(
      id: 'surah_1',
      title: 'سورة الفاتحة',
      description: 'فاتحة الكتاب',
      category: 'قرآن',
      createdAt: DateTime.now(),
    ),
  ),
);
```

### ج) حذف عنصر
```dart
context.read<FavoritesBloc>().add(
  RemoveFavorite(
    userId: firebaseUser.uid,
    itemId: 'surah_1',
  ),
);
```

### د) التحقق من وجود عنصر
```dart
context.read<FavoritesBloc>().add(
  CheckIfFavorite(
    userId: firebaseUser.uid,
    itemId: 'surah_1',
  ),
);

// في الـ BlocBuilder
if (state is FavoritesLoaded && state.isItemFavorite) {
  // عرض أيقونة القلب الممتلئة
}
```

### هـ) حذف جميع المفضلات
```dart
context.read<FavoritesBloc>().add(
  ClearAllFavorites(userId: firebaseUser.uid),
);
```

---

## 🔄 تدفق البيانات

```
User Action
    ↓
FavoritesEvent
    ↓
FavoritesBloc._onEventHandler()
    ↓
FavoritesRepository.method()
    ↓
FavoritesRemoteDataSource.firebaseMethod()
    ↓
Firestore
    ↓
Stream<List<FavoriteItemModel>>
    ↓
Emit FavoritesLoaded(favorites)
    ↓
BlocBuilder rebuilds UI
```

---

## 🚀 الميزات

✅ **تحديثات فورية**: استخدام Firestore Streams للحصول على تحديثات فورية
✅ **معالجة الأخطاء**: معالجة شاملة للأخطاء والاستثناءات
✅ **Clean Architecture**: فصل تام بين الطبقات
✅ **Equatable**: مقارنة آمنة للحالات والأحداث
✅ **Null Safety**: تطبيق كامل للـ Null Safety
✅ **Scalability**: سهولة التوسع والإضافة

---

## 📦 التكامل مع main.dart

```dart
// في main()
await configureDependencies();

// في BlocProvider
BlocProvider<FavoritesBloc>(
  create: (context) => getIt<FavoritesBloc>(),
  child: MyApp(),
)
```

---

## 🧪 مثال الاستخدام الكامل

انظر ملف: `favorites_screen.dart`

يحتوي على مثال كامل يوضح:
- تحميل المفضلات
- إضافة عنصر جديد
- حذف عنصر
- عرض الأخطاء والنجاح
- التعامل مع حالات مختلفة (Loading, Error, Empty, Loaded)

---

## 💡 نصائح مهمة

### 1. تجنب memory leaks
```dart
@override
void dispose() {
  _favoritesBloc.close(); // ✅ مهم جداً
  super.dispose();
}
```

### 2. استخدام buildWhen للتحكم في إعادة البناء
```dart
BlocBuilder<FavoritesBloc, FavoritesState>(
  buildWhen: (previous, current) {
    // أعد البناء فقط عند تغيير الحالة المهمة
    return current is FavoritesLoading || 
           current is FavoritesLoaded;
  },
  builder: (context, state) => ...,
)
```

### 3. استخدام BlocListener للعمليات الجانبية
```dart
BlocListener<FavoritesBloc, FavoritesState>(
  listener: (context, state) {
    if (state is FavoritesError) {
      // إظهار الأخطاء
    }
  },
  child: BlocBuilder(...)
)
```

---

## 🔐 Firestore Security Rules

```javascript
// في Firebase Console
match /users/{userId}/favorites/{document=**} {
  allow read, write: if request.auth.uid == userId;
}
```

---

## 🐛 معالجة الأخطاء الشائعة

### الخطأ: No Firestore instance
```dart
// ✅ تأكد من وجود:
getIt.registerLazySingleton<FirebaseFirestore>(
  () => FirebaseFirestore.instance,
);
```

### الخطأ: التحديثات لا تظهر
```dart
// ✅ تأكد من:
// 1. اشتراكك في Stream بشكل صحيح
// 2. استدعاء LoadFavorites عند فتح الشاشة
// 3. عدم إغلاق Bloc قبل الانتهاء
```

### الخطأ: تكرار العناصر
```dart
// ✅ استخدم:
getIt.registerFactory(() => FavoritesBloc(...));
// بدلاً من:
// getIt.registerLazySingleton(() => FavoritesBloc(...));
```

---

## 📝 ملفات المشروع

| الملف | الوصف |
|------|------|
| `favorite_item.dart` | Entity مع Equatable |
| `favorites_repository.dart` | Abstract Repository |
| `favorite_item_model.dart` | Model للتحويل من JSON |
| `favorites_remote_data_source.dart` | Firestore Implementation |
| `favorites_repository_impl.dart` | Repository Implementation |
| `favorites_event.dart` | جميع الأحداث |
| `favorites_state.dart` | جميع الحالات |
| `favorites_bloc.dart` | Bloc الرئيسي |
| `favorites_screen.dart` | مثال كامل للاستخدام |

---

## 🎓 موارد إضافية

- [Flutter Bloc Documentation](https://bloclibrary.dev/)
- [Clean Architecture in Flutter](https://resocoder.com/clean-architecture)
- [Firebase Firestore Documentation](https://firebase.google.com/docs/firestore)

---

✨ **تم إنشاء هذا المودول باتباع أفضل الممارسات في تطوير Flutter!**
