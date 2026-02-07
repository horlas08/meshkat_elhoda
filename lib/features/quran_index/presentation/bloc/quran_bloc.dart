import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_surahs.dart';
import '../../domain/usecases/get_surah_by_number.dart';
import '../../domain/usecases/get_juz_surahs.dart';
import '../../domain/usecases/get_ayah_tafsir.dart';
import '../../domain/usecases/get_reciters.dart';
import '../../domain/usecases/get_last_position.dart';
import '../../domain/usecases/save_last_position.dart';
import '../../domain/usecases/get_audio_url.dart';
import 'quran_event.dart';
import 'quran_state.dart';
import '../../domain/entities/surah_entity.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final GetAllSurahs getAllSurahs;
  final GetSurahByNumber getSurahByNumber;
  final GetJuzSurahs getJuzSurahs;
  final GetAyahTafsir getAyahTafsir;
  final GetReciters getReciters;
  final SaveLastPosition saveLastPosition;
  final GetLastPosition getLastPosition;
  final GetAudioUrl getAudioUrl;

  // Track the last loaded surah to restore after tafsir closes
  int? _lastSurahNumber;
  String? _lastReciterId;
  QuranState? _lastSurahState;

  QuranBloc({
    required this.getAllSurahs,
    required this.getSurahByNumber,
    required this.getJuzSurahs,
    required this.getAyahTafsir,
    required this.getReciters,
    required this.saveLastPosition,
    required this.getLastPosition,
    required this.getAudioUrl,
  }) : super(QuranInitial()) {
    on<GetAllSurahsEvent>(_onGetAllSurahs);
    on<GetSurahByNumberEvent>(_onGetSurahByNumber);
    on<GetJuzSurahsEvent>(_onGetJuzSurahs);
    on<GetAyahTafsirEvent>(_onGetAyahTafsir);
    on<GetRecitersEvent>(_onGetReciters);
    on<SaveLastPositionEvent>(_onSaveLastPosition);
    on<GetLastPositionEvent>(_onGetLastPosition);
    on<GetAudioUrlEvent>(_onGetAudioUrl);
    on<ResetStateEvent>((event, emit) => emit(QuranInitial()));

    // أضف معالجة الـ ClearTafsirEvent هنا
    on<ClearTafsirEvent>(_onClearTafsir);

    // أضف معالجة البحث
    on<SearchSurahsEvent>(_onSearchSurahs);

    // أضف معالجة تحميل القرآن كاملاً
    on<GetAllQuranAyahsEvent>(_onGetAllQuranAyahs);
  }

  Future<void> _onGetAllSurahs(
    GetAllSurahsEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(Loading());
    final result = await getAllSurahs();
    result.fold(
      (failure) => emit(Error(failure.message)),
      (surahs) => emit(SurahsLoaded(surahs)),
    );
  }

  Future<void> _onGetSurahByNumber(
    GetSurahByNumberEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(Loading());
    // Store the surah number and reciter for later restoration
    _lastSurahNumber = event.number;
    _lastReciterId = event.reciterId;
    final result = await getSurahByNumber(
      event.number,
      reciterId: event.reciterId,
      language: event.language,
    );
    result.fold((failure) => emit(Error(failure.message)), (ayahs) {
      final loadedState = SurahAyahsLoaded(ayahs);
      _lastSurahState = loadedState;
      emit(loadedState);
    });
  }

  Future<void> _onGetJuzSurahs(
    GetJuzSurahsEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(Loading());
    final result = await getJuzSurahs(event.number);
    result.fold(
      (failure) => emit(Error(failure.message)),
      (juz) => emit(JuzLoaded(juz)),
    );
  }

  Future<void> _onGetAyahTafsir(
    GetAyahTafsirEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(Loading());
    final result = await getAyahTafsir(
      event.surahNumber,
      event.ayahNumber,
      tafsirId: event.tafsirId,
    );
    result.fold(
      (failure) => emit(Error(failure.message)),
      (tafsir) => emit(TafsirLoaded(tafsir)),
    );
  }

  Future<void> _onGetReciters(
    GetRecitersEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(Loading());
    final result = await getReciters();
    result.fold(
      (failure) => emit(Error(failure.message)),
      (reciters) => emit(RecitersLoaded(reciters)),
    );
  }

  Future<void> _onSaveLastPosition(
    SaveLastPositionEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(Loading());
    final result = await saveLastPosition(event.surahNumber, event.ayahNumber);
    result.fold(
      (failure) => emit(Error(failure.message)),
      (_) => emit(LastPositionSaved()),
    );
  }

  Future<void> _onGetLastPosition(
    GetLastPositionEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(Loading());
    final result = await getLastPosition();
    result.fold(
      (failure) => emit(Error(failure.message)),
      (position) => emit(
        LastPositionLoaded(
          surahNumber: position.surahNumber,
          ayahNumber: position.ayahNumber,
        ),
      ),
    );
  }

  Future<void> _onGetAudioUrl(
    GetAudioUrlEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(Loading());
    final result = await getAudioUrl(event.surahNumber, event.reciterId);
    result.fold(
      (failure) => emit(Error(failure.message)),
      (url) => emit(AudioUrlLoaded(url)),
    );
  }

  // أضف هذه الدالة لمعالجة ClearTafsirEvent
  Future<void> _onClearTafsir(
    ClearTafsirEvent event,
    Emitter<QuranState> emit,
  ) async {
    // إعادة تحميل السورة بعد إغلاق التفسير
    if (_lastSurahState != null) {
      // استخدم الحالة المحفوظة مباشرة
      emit(_lastSurahState!);
    } else if (_lastSurahNumber != null) {
      // إذا لم تكن الحالة محفوظة، أعد تحميل السورة
      emit(Loading());
      final result = await getSurahByNumber(
        _lastSurahNumber!,
        reciterId: _lastReciterId,
      );
      result.fold((failure) => emit(Error(failure.message)), (ayahs) {
        final loadedState = SurahAyahsLoaded(ayahs);
        _lastSurahState = loadedState;
        emit(loadedState);
      });
    } else {
      // حالة احتياطية
      emit(QuranInitial());
    }
  }

  Future<void> _onSearchSurahs(
    SearchSurahsEvent event,
    Emitter<QuranState> emit,
  ) async {
    if (event.query.isEmpty) {
      // إذا كانت البحث فارغة، أرجع كل السور
      final result = await getAllSurahs();
      result.fold(
        (failure) => emit(Error(failure.message)),
        (surahs) => emit(SurahsLoaded(surahs)),
      );
      return;
    }
    final query = event.query.toLowerCase();

    // استخدم فلتر على event.allSurahs للحصول على قائمة مترجمة من النوع الصحيح
    final List<SurahEntity> results = event.allSurahs
        .where((surah) {
          final arabicName = surah.name?.toString().toLowerCase() ?? '';
          final englishName = surah.englishName?.toString().toLowerCase() ?? '';
          final englishNameTranslation =
              surah.englishNameTranslation?.toString().toLowerCase() ?? '';
          final numberMatch = surah.number?.toString() == event.query;
          return arabicName.contains(query) ||
              englishName.contains(query) ||
              englishNameTranslation.contains(query) ||
              numberMatch;
        })
        .toList()
        .cast<SurahEntity>();

    emit(SearchResultsLoaded(results));
  }

  Future<void> _onGetAllQuranAyahs(
    GetAllQuranAyahsEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(Loading());

    // جلب جميع الآيات من السورة 1 إلى 114
    final allAyahs = <dynamic>[];

    for (int i = 1; i <= 114; i++) {
      final result = await getSurahByNumber(i, reciterId: event.reciterId);
      result.fold(
        (failure) {
          // في حالة الخطأ، نتوقف ونعرض الخطأ
          emit(Error(failure.message));
          return;
        },
        (ayahs) {
          allAyahs.addAll(ayahs);
        },
      );
    }

    // إذا نجحنا في جلب كل الآيات
    if (allAyahs.isNotEmpty) {
      emit(SurahAyahsLoaded(allAyahs.cast()));
    }
  }
}
