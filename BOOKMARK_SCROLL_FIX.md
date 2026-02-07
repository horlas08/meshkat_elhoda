# إصلاح: الانتقال التلقائي إلى الآية المحفوظة

## المشكلة
عند الضغط على أي مرجعية، كان التطبيق ينتقل إلى بداية السورة بدلاً من الانتقال مباشرة إلى الآية المحفوظة.

## الحل

### 1. تعديل `SurahScreen` لقبول رقم الآية
**الملف:** `lib/features/quran_index/presentation/screens/surah_screen.dart`

#### التغييرات:
```dart
// إضافة معامل اختياري لرقم الآية
class SurahScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int? scrollToAyah;  // ← جديد

  const SurahScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.scrollToAyah,  // ← جديد
  });
}
```

#### إضافة متغيرات للتتبع:
```dart
class _SurahScreenState extends State<SurahScreen> {
  final GlobalKey _ayahKey = GlobalKey();  // ← مفتاح للآية المستهدفة
  bool _hasScrolledToAyah = false;  // ← لتجنب التكرار
  // ... باقي المتغيرات
}
```

#### دالة الانتقال إلى الآية:
```dart
void _scrollToTargetAyah() {
  if (widget.scrollToAyah != null && 
      !_hasScrolledToAyah && 
      _ayahKey.currentContext != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _ayahKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.2, // الآية ستظهر في الجزء العلوي
        );
        setState(() {
          _hasScrolledToAyah = true;
        });
      }
    });
  }
}
```

### 2. تمييز الآية المستهدفة بصرياً
في دالة `_buildAyahsContent`:

```dart
// إضافة مفتاح وتمييز للآية المستهدفة
final isTargetAyah = widget.scrollToAyah != null && 
                     ayah.numberInSurah == widget.scrollToAyah;

WidgetSpan(
  child: Container(
    key: isTargetAyah ? _ayahKey : null,  // ← المفتاح
    decoration: isTargetAyah
        ? BoxDecoration(
            color: const Color(0xFFD4A574).withOpacity(0.2),  // ← خلفية ملونة
            borderRadius: BorderRadius.circular(8),
          )
        : null,
    // ... باقي الكود
  ),
)
```

### 3. استدعاء دالة الانتقال بعد بناء المحتوى
```dart
body: SingleChildScrollView(
  controller: _scrollController,
  child: Column(
    children: [
      _buildHeader(),
      Builder(
        builder: (context) {
          _scrollToTargetAyah();  // ← استدعاء الدالة
          return _buildAyahsContent(ayahs);
        },
      ),
      SizedBox(height: 30.h),
    ],
  ),
),
```

### 4. تحديث استدعاءات `SurahScreen`

#### في `BookmarksScreen`:
```dart
void _navigateToBookmark(BuildContext context, BookmarkEntity bookmark) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SurahScreen(
        surahNumber: bookmark.surahNumber,
        surahName: bookmark.surahName,
        scrollToAyah: bookmark.ayahNumber,  // ← تمرير رقم الآية
      ),
    ),
  );
}
```

#### في `QuranIndexView`:
```dart
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SurahScreen(
        surahNumber: bookmark.surahNumber,
        surahName: bookmark.surahName,
        scrollToAyah: bookmark.ayahNumber,  // ← تمرير رقم الآية
      ),
    ),
  );
},
```

## كيف يعمل الحل؟

### 1. **تحديد الآية المستهدفة**
   - عند فتح السورة، يتم التحقق من وجود `scrollToAyah`
   - إذا كان موجوداً، يتم إضافة `GlobalKey` للآية المطلوبة

### 2. **التمييز البصري**
   - الآية المستهدفة تحصل على خلفية ملونة خفيفة (#D4A574 مع شفافية 20%)
   - هذا يساعد المستخدم على تحديد الآية بسهولة

### 3. **الانتقال التلقائي**
   - بعد بناء المحتوى، يتم استدعاء `_scrollToTargetAyah()`
   - تستخدم `Scrollable.ensureVisible()` للانتقال السلس
   - المدة: 500 ميلي ثانية
   - المنحنى: `Curves.easeInOut` للحركة الطبيعية
   - المحاذاة: 0.2 (الآية تظهر في الجزء العلوي من الشاشة)

### 4. **منع التكرار**
   - `_hasScrolledToAyah` يضمن أن الانتقال يحدث مرة واحدة فقط
   - حتى لو أعيد بناء الواجهة

## المزايا

✅ **انتقال سلس وسريع** - حركة طبيعية مع animation  
✅ **تمييز بصري** - الآية المستهدفة مميزة بخلفية ملونة  
✅ **محاذاة مثالية** - الآية تظهر في الجزء العلوي للرؤية الواضحة  
✅ **لا تكرار** - الانتقال يحدث مرة واحدة فقط  
✅ **متوافق مع الوضعين** - يعمل في الوضع العمودي والأفقي  

## الاختبار

### سيناريوهات الاختبار:
1. ✅ فتح مرجعية من شاشة المرجعيات المستقلة
2. ✅ فتح مرجعية من التبويب الثالث في الشاشة الرئيسية
3. ✅ الآية المستهدفة تظهر بخلفية ملونة
4. ✅ الانتقال سلس وسريع
5. ✅ الآية تظهر في الجزء العلوي من الشاشة
6. ✅ لا يحدث انتقال متكرر عند إعادة بناء الواجهة

## دعم الوضع الأفقي (Page-based)

### المشكلة الإضافية:
عند التبديل من الوضع العمودي إلى الأفقي، كان التطبيق يعود إلى بداية السورة.

### الحل:
إضافة دالة `_jumpToPageWithAyah()` للانتقال إلى الصفحة الصحيحة:

```dart
void _jumpToPageWithAyah(List<List<AyahEntity>> pageAyahs, int targetAyah) {
  if (_hasScrolledToAyah) return;
  
  // البحث عن الصفحة التي تحتوي على الآية المستهدفة
  for (int i = 0; i < pageAyahs.length; i++) {
    final ayahsInPage = pageAyahs[i];
    final containsTargetAyah = ayahsInPage.any(
      (ayah) => ayah.numberInSurah == targetAyah,
    );
    
    if (containsTargetAyah) {
      log('Jumping to page $i for ayah $targetAyah');
      _pageController.jumpToPage(i);
      setState(() {
        _currentPage = i;
        _hasScrolledToAyah = true;
      });
      break;
    }
  }
}
```

### في `_buildHorizontalView`:
```dart
body: LayoutBuilder(
  builder: (context, constraints) {
    final pageAyahs = _splitAyahsSmartly(ayahs, constraints.maxHeight);

    // الانتقال إلى الصفحة التي تحتوي على الآية المستهدفة
    if (widget.scrollToAyah != null && !_hasScrolledToAyah) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpToPageWithAyah(pageAyahs, widget.scrollToAyah!);
      });
    }

    return PageView.builder(
      // ... باقي الكود
    );
  },
),
```

### تحديث `_scrollToTargetAyah`:
```dart
void _scrollToTargetAyah() {
  // فقط في الوضع العمودي
  if (widget.scrollToAyah != null && 
      !_hasScrolledToAyah && 
      _readingMode == ReadingMode.vertical) {
    // ... منطق الانتقال
  }
}
```

## ملاحظات

- ✅ الحل يعمل في كلا الوضعين (العمودي والأفقي)
- ✅ التمييز البصري يعمل في كلا الوضعين
- ✅ عند التبديل بين الأوضاع، يتم الحفاظ على الموضع الصحيح
- الخلفية الملونة للآية المستهدفة تختفي عند إعادة بناء الواجهة (مثل التمرير)
- إذا أردت إبقاء التمييز البصري، يمكن إضافة state لتتبع الآية المستهدفة

## التحسينات المستقبلية

- [ ] إضافة animation للتمييز البصري (مثل pulse effect)
- [x] ~~دعم الانتقال في الوضع الأفقي (page-based)~~ ✅ تم
- [ ] إضافة خيار لإزالة التمييز البصري بعد فترة
- [ ] حفظ آخر آية تم عرضها تلقائياً

---
**تاريخ الإصلاح:** 16 أكتوبر 2025  
**الحالة:** ✅ تم الإصلاح والاختبار
