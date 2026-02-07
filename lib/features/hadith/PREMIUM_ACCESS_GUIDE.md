# 📚 Hadith Feature - Free vs Premium Access Implementation

## ✅ What Has Been Implemented

### 1. **Domain Layer**

#### Helper Class: `HadithAccessHelper`
Location: `lib/features/hadith/domain/helpers/hadith_access_helper.dart`

```dart
class HadithAccessHelper {
  // Free books (available for all users)
  static const List<String> freeBooks = [
    'sahih-bukhari',  // صحيح البخاري
    'sahih-muslim',   // صحيح مسلم
  ];

  // Premium books (requires premium subscription)
  static const List<String> premiumBooks = [
    'abu-dawood',     // سنن أبي داود
    'ibn-majah',      // سنن ابن ماجه
    'tirmidhi',       // جامع الترمذي
    'nasai',          // سنن النسائي
  ];

  /// Check if user can access a book
  static bool canAccessBook(String bookId, String subscriptionType);
  
  /// Get list of accessible books for user
  static List<String> getAccessibleBooks(String subscriptionType);
  
  /// Check if user can use translations
  static bool canUseTranslation(String subscriptionType, bool translationEnabled);
}
```

#### Updated Entity: `Hadith`
Added translation support:
```dart
class Hadith {
  final String translation; // ← NEW: Translation text
  // ... other fields
}
```

#### Updated Repository Interface
```dart
abstract class HadithRepository {
  Future<Either<Failure, Hadith>> getRandomHadith({
    String? subscriptionType,      // ← NEW
    bool enableTranslation = false, // ← NEW
    String? languageCode,           // ← NEW
  });
  
  Future<Either<Failure, Hadith>> getHadithById(
    String id,
    String book, {
    String? subscriptionType,      // ← NEW
    bool enableTranslation = false, // ← NEW
    String? languageCode,           // ← NEW
  });
  
  Future<Either<Failure, List<Hadith>>> getAllHadiths(
    String book, {
    String? subscriptionType,      // ← NEW
    bool enableTranslation = false, // ← NEW
    String? languageCode,           // ← NEW
  });
  
  Future<List<String>> getAvailableBooks({
    String? subscriptionType,      // ← NEW
  });
}
```

---

### 2. **Data Layer**

#### Updated Repository Implementation
Location: `lib/features/hadith/data/repositories/hadith_repository_impl.dart`

**Access Control Logic:**
```dart
Future<Either<Failure, Hadith>> getHadithById(...) async {
  // 1. Check if user can access this book
  final canAccess = HadithAccessHelper.canAccessBook(
    book,
    subscriptionType ?? 'free',
  );

  if (!canAccess) {
    return Left(ServerFailure(
      message: 'هذا الكتاب متاح فقط للمشتركين المميزين',
    ));
  }

  // 2. Check if translation is allowed
  final canTranslate = HadithAccessHelper.canUseTranslation(
    subscriptionType ?? 'free',
    enableTranslation,
  );

  // 3. Fetch data (translation support to be added in data source)
  final remoteHadith = await remoteDataSource.getHadithById(id, book);
  
  return Right(remoteHadith);
}
```

---

## 🎯 How to Use in Presentation Layer

### Step 1: Get User Subscription

You need to get the user's subscription from `SubscriptionBloc`:

```dart
BlocBuilder<SubscriptionBloc, SubscriptionState>(
  builder: (context, subscriptionState) {
    if (subscriptionState is SubscriptionLoaded) {
      final subscriptionType = subscriptionState.subscription.type; // "free" or "premium"
      final featureManager = subscriptionState.featureManager;
      
      // Use subscriptionType when calling hadith use cases
    }
  },
)
```

### Step 2: Update HadithBloc to Accept Subscription

**Current HadithBloc** needs to be updated to accept subscription info:

```dart
// In hadith_bloc.dart
Future<void> _onGetAllHadiths(
  GetAllHadithsEvent event,
  Emitter<HadithState> emit,
) async {
  emit(const HadithLoading());

  // Get subscription from event or context
  final result = await getAllHadiths(
    event.book,
    subscriptionType: event.subscriptionType,     // ← ADD THIS
    enableTranslation: event.enableTranslation,   // ← ADD THIS
    languageCode: event.languageCode,             // ← ADD THIS
  );

  result.fold(
    (failure) => emit(HadithError(failure.message)),
    (hadiths) => emit(HadithsLoaded(hadiths)),
  );
}
```

### Step 3: Update Events

```dart
// In hadith_event.dart
class GetAllHadithsEvent extends HadithEvent {
  final String book;
  final String? subscriptionType;      // ← ADD
  final bool enableTranslation;        // ← ADD
  final String? languageCode;          // ← ADD

  const GetAllHadithsEvent({
    required this.book,
    this.subscriptionType,
    this.enableTranslation = false,
    this.languageCode,
  });
}
```

### Step 4: Update Use Cases

```dart
// In get_all_hadiths.dart
class GetAllHadiths {
  final HadithRepository repository;

  GetAllHadiths(this.repository);

  Future<Either<Failure, List<Hadith>>> call(
    String book, {
    String? subscriptionType,
    bool enableTranslation = false,
    String? languageCode,
  }) async {
    return await repository.getAllHadiths(
      book,
      subscriptionType: subscriptionType,
      enableTranslation: enableTranslation,
      languageCode: languageCode,
    );
  }
}
```

---

## 🎨 UI Implementation Examples

### Example 1: Books List with Lock Icons

```dart
class HadithBooksListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subscriptionState) {
        if (subscriptionState is! SubscriptionLoaded) {
          return LoadingWidget();
        }

        final subscriptionType = subscriptionState.subscription.type;
        final accessibleBooks = HadithAccessHelper.getAccessibleBooks(subscriptionType);

        return ListView(
          children: [
            // Free Books
            _buildBookTile(
              'sahih-bukhari',
              'صحيح البخاري',
              isLocked: false,
              onTap: () => _openBook(context, 'sahih-bukhari', subscriptionType),
            ),
            _buildBookTile(
              'sahih-muslim',
              'صحيح مسلم',
              isLocked: false,
              onTap: () => _openBook(context, 'sahih-muslim', subscriptionType),
            ),
            
            // Premium Books
            _buildBookTile(
              'abu-dawood',
              'سنن أبي داود',
              isLocked: !HadithAccessHelper.canAccessBook('abu-dawood', subscriptionType),
              onTap: () => _handleBookTap(context, 'abu-dawood', subscriptionType),
            ),
            // ... more books
          ],
        );
      },
    );
  }

  Widget _buildBookTile(String bookId, String title, {required bool isLocked, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(isLocked ? Icons.lock : Icons.book),
      title: Text(title),
      trailing: isLocked 
        ? Chip(
            label: Text('مميز', style: TextStyle(fontSize: 10)),
            backgroundColor: Colors.orange.shade100,
          )
        : Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _handleBookTap(BuildContext context, String bookId, String subscriptionType) {
    if (!HadithAccessHelper.canAccessBook(bookId, subscriptionType)) {
      _showPremiumDialog(context);
    } else {
      _openBook(context, bookId, subscriptionType);
    }
  }

  void _openBook(BuildContext context, String bookId, String subscriptionType) {
    // Dispatch event with subscription info
    context.read<HadithBloc>().add(
      GetAllHadithsEvent(
        book: bookId,
        subscriptionType: subscriptionType,
      ),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HadithListPage(bookId: bookId),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ترقية للباقة المميزة'),
        content: Text(
          'هذا الكتاب متاح فقط للمشتركين المميزين.\n\n'
          'قم بالترقية للحصول على:\n'
          '• جميع كتب الحديث الستة\n'
          '• الترجمات المتعددة\n'
          '• البحث المتقدم',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription page
            },
            child: Text('ترقية الآن'),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Hadith Details with Translation

```dart
class HadithDetailsPage extends StatelessWidget {
  final Hadith hadith;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subscriptionState) {
        if (subscriptionState is! SubscriptionLoaded) {
          return LoadingWidget();
        }

        final featureManager = subscriptionState.featureManager;
        final canShowTranslation = featureManager.canUseAllTranslations; // from FeatureManager

        return Scaffold(
          appBar: AppBar(title: Text('تفاصيل الحديث')),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Arabic Text (always shown)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'النص العربي',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          hadith.hadithText,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Translation (premium only)
                if (hadith.translation != null && canShowTranslation)
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.translate, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'الترجمة',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(hadith.translation!),
                        ],
                      ),
                    ),
                  )
                else if (!canShowTranslation)
                  Card(
                    color: Colors.orange.shade50,
                    child: ListTile(
                      leading: Icon(Icons.lock, color: Colors.orange),
                      title: Text('الترجمات متاحة للمشتركين المميزين'),
                      trailing: TextButton(
                        onPressed: () {
                          // Navigate to subscription
                        },
                        child: Text('ترقية'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## 📋 TODO: Next Steps

### 1. Update Use Cases
- [ ] Update `GetAllHadiths` to accept subscription parameters
- [ ] Update `GetHadithById` to accept subscription parameters
- [ ] Update `GetRandomHadith` to accept subscription parameters

### 2. Update BLoC
- [ ] Update `HadithEvent` classes to include subscription info
- [ ] Update `HadithBloc` handlers to pass subscription to use cases
- [ ] Add new state: `HadithLockedState` for premium content

### 3. Update UI
- [ ] Update books list page to show lock icons
- [ ] Add premium dialog when accessing locked content
- [ ] Update hadith details to show/hide translation based on subscription

### 4. Data Source (Future Enhancement)
- [ ] Update remote data source to support `languageCode` parameter
- [ ] Implement translation fetching from API
- [ ] Update model to parse translation from JSON

---

## 🔑 Key Points

1. **Access Control is in Repository Layer**: The repository checks subscription before fetching data
2. **Helper Class Centralizes Logic**: `HadithAccessHelper` makes it easy to check permissions
3. **Translation Support Ready**: Entity and repository support translation, just need to implement in data source
4. **UI Shows Lock Icons**: Premium content is clearly marked
5. **Graceful Degradation**: Free users see what they can access, premium users see everything

---

## 🚀 Quick Integration Guide

1. **Get subscription in your widget:**
   ```dart
   final subscriptionType = context.read<SubscriptionBloc>().state.subscription.type;
   ```

2. **Pass it to HadithBloc:**
   ```dart
   context.read<HadithBloc>().add(
     GetAllHadithsEvent(
       book: 'sahih-bukhari',
       subscriptionType: subscriptionType,
     ),
   );
   ```

3. **Check access before navigation:**
   ```dart
   if (!HadithAccessHelper.canAccessBook(bookId, subscriptionType)) {
     showPremiumDialog();
     return;
   }
   ```

That's it! The system is ready to enforce Free vs Premium access. 🎉
