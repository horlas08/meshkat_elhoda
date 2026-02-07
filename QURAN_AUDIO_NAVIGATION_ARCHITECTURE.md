# ✅ نمط الملاحة والحالة للصوت - شامل ومعماري

## **المشكلة:**
عند الضغط على back (pop) من `AudioPlayerScreen` إلى `AudioSurahsScreen`، البيانات تختفي.

---

## **السبب الجذري:**

### **1. Bloc في MultiBlocProvider (جيد ✓)**
```dart
// في main.dart
BlocProvider<QuranAudioBloc>(
  create: (context) => getIt<QuranAudioBloc>(),
),
```
✅ Bloc مشترك في الأعلى - جيد!

### **2. لكن المشكلة في الملاحة والاستماع**

#### **❌ المشكلة الأولى: عدم الاستماع للحالة في الشاشات**
```dart
// في audio_surahs_screen.dart
_loadData(); // في البناء مرة أخرى - مشكلة!
```
⚠️ هذا يُعيد تحميل البيانات في كل build، مما قد يسبب مشاكل.

#### **❌ المشكلة الثانية: عدم حفظ حالة الـ Bloc**
```dart
// الـ Bloc يحتفظ بالبيانات، لكن الشاشة لا تستمع إليها بشكل صحيح
```

---

## **الحل الصحيح: BLoC State Persistence Pattern**

### **المفهوم:**
```
┌─────────────────────────────────────┐
│          MultiBlocProvider          │
│  (QuranAudioBloc - في الأعلى دائماً) │
└────────────────┬────────────────────┘
                 │
         ┌───────┴────────┐
         │                │
    ┌────▼──────┐  ┌─────▼────────┐
    │ Reciters  │  │ Surahs       │
    │ Screen    │  │ Screen       │
    │           │  │              │
    │Push ──────┼──┴─► Player    │
    │           │      Screen     │
    │  ◄────Pop─┼──────          │
    │           │
    └───────────┘
```

**النقاط الأساسية:**
1. ✅ Bloc في المستوى الأعلى - يبقى طوال الوقت
2. ✅ الشاشات تستمع للحالة - لا تحمّل مرة أخرى
3. ✅ عند Pop، البيانات موجودة بالفعل في الـ Bloc

---

## **الحل الموصى به: 3 استراتيجيات**

### **استراتيجية 1: استخدام BlocListener + BlocBuilder (الأفضل)**

#### **خطوة 1: تعديل audio_reciters_screen.dart**

```dart
class AudioRecitersScreen extends StatefulWidget {
  final String language;
  const AudioRecitersScreen({Key? key, required this.language}) : super(key: key);

  @override
  State<AudioRecitersScreen> createState() => _AudioRecitersScreenState();
}

class _AudioRecitersScreenState extends State<AudioRecitersScreen> {
  late TextEditingController _searchController;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحميل المرة الأولى فقط، وليس في كل build
    if (_isFirstLoad) {
      _isFirstLoad = false;
      context.read<QuranAudioBloc>().add(
        LoadRecitersEvent(language: widget.language),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'القراء' : 'Reciters')),
      body: BlocBuilder<QuranAudioBloc, QuranAudioState>(
        buildWhen: (previous, current) {
          // فقط أعد البناء عند تغيير ريسيترز
          return current is RecitersLoaded || current is RecitersLoading || current is RecitersError;
        },
        builder: (context, state) {
          if (state is RecitersLoading) {
            return const Center(child: QuranLottieLoading());
          }

          if (state is RecitersError) {
            return Center(child: Text(state.message));
          }

          if (state is RecitersLoaded) {
            final reciters = state.filteredReciters.isNotEmpty
                ? state.filteredReciters
                : state.reciters;

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<QuranAudioBloc>().add(
                        SearchRecitersEvent(query: query),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: isArabic ? 'ابحث عن قارئ...' : 'Search reciters...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // Reciters list
                Expanded(
                  child: reciters.isEmpty
                      ? Center(child: Text(isArabic ? 'لا توجد نتائج' : 'No results'))
                      : ListView.builder(
                          itemCount: reciters.length,
                          itemBuilder: (context, index) {
                            final reciter = reciters[index];
                            return ReciterCard(
                              reciter: reciter,
                              onTap: () {
                                // ✅ اختيار القارئ ثم الذهاب للسور
                                context.read<QuranAudioBloc>().add(
                                  SelectReciterEvent(reciter: reciter),
                                );
                                context.read<QuranAudioBloc>().add(
                                  LoadSurahsEvent(reciter: reciter),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AudioSurahsScreen(reciter: reciter),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

#### **خطوة 2: تعديل audio_surahs_screen.dart**

```dart
class AudioSurahsScreen extends StatefulWidget {
  final Reciter reciter;
  const AudioSurahsScreen({Key? key, required this.reciter}) : super(key: key);

  @override
  State<AudioSurahsScreen> createState() => _AudioSurahsScreenState();
}

class _AudioSurahsScreenState extends State<AudioSurahsScreen> {
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحميل السور المرة الأولى فقط
    if (_isFirstLoad) {
      _isFirstLoad = false;
      context.read<QuranAudioBloc>().add(
        LoadSurahsEvent(reciter: widget.reciter),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return WillPopScope(
      onWillPop: () async {
        // عند الضغط على الرجوع، البيانات تبقى محفوظة في Bloc
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isArabic ? 'السور' : 'Surahs'),
              Text(widget.reciter.name, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        body: BlocBuilder<QuranAudioBloc, QuranAudioState>(
          buildWhen: (previous, current) {
            // فقط أعد البناء عند تغيير السور
            return current is SurahsLoaded || current is SurahsLoading || current is SurahsError;
          },
          builder: (context, state) {
            if (state is SurahsLoading) {
              return const Center(child: QuranLottieLoading());
            }

            if (state is SurahsError) {
              return Center(child: Text(state.message));
            }

            if (state is SurahsLoaded) {
              final surahs = state.surahs;

              // Filter surahs based on reciter's available surahs
              final surahNumbers = widget.reciter.suras
                  .split(',')
                  .map((s) => s.trim())
                  .toSet();
              final availableSurahs = surahs
                  .where((surah) => surahNumbers.contains(surah.number.toString()))
                  .toList();

              return ListView.builder(
                itemCount: availableSurahs.length,
                itemBuilder: (context, index) {
                  final surah = availableSurahs[index];
                  return SurahCard(
                    surah: surah,
                    reciter: widget.reciter,
                    onPlayTap: () {
                      // ✅ إنشاء playlist وذهاب للمشغل
                      final audioTracks = <AudioTrack>[];
                      for (var s in availableSurahs) {
                        final surahNum = s.number.toString().padLeft(3, '0');
                        audioTracks.add(
                          AudioTrack(
                            surahNumber: s.number.toString(),
                            surahName: s.name,
                            reciterName: widget.reciter.name,
                            audioUrl: '${widget.reciter.server}/$surahNum.mp3',
                            ayahCount: s.ayahCount,
                          ),
                        );
                      }

                      final selectedIndex = availableSurahs.indexOf(surah);

                      context.read<QuranAudioBloc>().add(
                        LoadPlaylistEvent(
                          playlist: audioTracks,
                          startIndex: selectedIndex,
                        ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AudioPlayerScreen(
                            playlist: audioTracks,
                            startIndex: selectedIndex,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
```

---

### **استراتيجية 2: استخدام Named Routes (بديل أفضل)**

```dart
// في main.dart - استبدل home بـ routes
MaterialApp(
  routes: {
    '/': (context) => const MainNavigationViews(),
    '/reciters': (context) => const AudioRecitersScreen(language: 'ar'),
    '/surahs': (context) => AudioSurahsScreen(
      reciter: _getCurrentReciter(), // من Bloc
    ),
    '/player': (context) => AudioPlayerScreen(
      playlist: _getCurrentPlaylist(), // من Bloc
      startIndex: _getCurrentIndex(),
    ),
  },
  onGenerateRoute: (settings) {
    // للملاحة الديناميكية
    if (settings.name == '/player') {
      return MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(
          playlist: context.read<QuranAudioBloc>().getCurrentPlaylist(),
          startIndex: 0,
        ),
      );
    }
    return null;
  },
)
```

---

### **استراتيجية 3: حفظ الحالة في Bloc Cache**

```dart
// في quran_audio_cubit.dart
class QuranAudioBloc extends Bloc<QuranAudioEvent, QuranAudioState> {
  final GetReciters getReciters;
  // ...

  // ✅ حفظ البيانات محلياً
  List<Reciter>? _cachedReciters;
  List<Surah>? _cachedSurahs;
  List<AudioTrack>? _cachedPlaylist;

  QuranAudioBloc({required this.getReciters, ...}) : super(const RecitersInitial()) {
    on<LoadRecitersEvent>(_onLoadReciters);
    on<LoadSurahsEvent>(_onLoadSurahs);
    // ...
  }

  // ✅ تحميل من الـ cache أولاً
  Future<void> _onLoadReciters(LoadRecitersEvent event, Emitter emit) async {
    if (_cachedReciters != null) {
      // إذا كانت البيانات موجودة في الـ cache، استخدمها فوراً
      emit(RecitersLoaded(
        reciters: _cachedReciters!,
        filteredReciters: _cachedReciters!,
      ));
      return;
    }

    // وإلا، حمّل من الـ API
    emit(RecitersLoading());
    try {
      final result = await getReciters(event.language);
      result.fold(
        (failure) => emit(RecitersError(message: failure.message)),
        (reciters) {
          _cachedReciters = reciters; // ✅ احفظ في الـ cache
          emit(RecitersLoaded(reciters: reciters, filteredReciters: reciters));
        },
      );
    } catch (e) {
      emit(RecitersError(message: e.toString()));
    }
  }

  // ✅ دالة للحصول على الـ cached data
  List<Reciter>? getCachedReciters() => _cachedReciters;
}
```

---

## **الخلاصة: أفضل ممارسات**

| المعيار | الحل |
|--------|------|
| **حيث يكون Bloc؟** | MultiBlocProvider في main.dart (أعلى المستوى) |
| **متى تحمّل البيانات؟** | في `didChangeDependencies` مرة واحدة فقط |
| **كيف تتجنب reload؟** | استخدم `buildWhen` و `_isFirstLoad` flag |
| **عند Pop كيف تحافظ على البيانات؟** | البيانات موجودة في Bloc (لا تختفي) |
| **هل تحتاج WillPopScope؟** | فقط للتحكم الإضافي (اختياري) |
| **الملاحة؟** | استخدم `Navigator.push` مع BlocProvider في top-level |

---

## **ملخص الكود الصحيح:**

```dart
// ✅ 1. Main.dart
MultiBlocProvider(
  providers: [
    BlocProvider<QuranAudioBloc>(
      create: (context) => getIt<QuranAudioBloc>(),
    ),
  ],
  child: MaterialApp(...),
)

// ✅ 2. Audio Reciters Screen
didChangeDependencies() {
  if (_isFirstLoad) {
    _isFirstLoad = false;
    context.read<QuranAudioBloc>().add(LoadRecitersEvent(...));
  }
}

// ✅ 3. BlocBuilder
BlocBuilder<QuranAudioBloc, QuranAudioState>(
  buildWhen: (prev, curr) => curr is RecitersLoaded || ...,
  builder: (context, state) { ... }
)

// ✅ 4. Navigation
Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
// البيانات تبقى في Bloc - لن تختفي عند pop!
```

---

## **النتيجة النهائية:**
✅ عند pop من player → السور محفوظة
✅ عند pop من السور → القراء محفوظة
✅ لا reload غير ضروري
✅ معمارية نظيفة وممكنة للصيانة

