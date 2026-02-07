import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/get_available_tafsirs.dart';
import '../../domain/usecases/get_available_reciters.dart';
import 'quran_settings_state.dart';

class QuranSettingsCubit extends Cubit<QuranSettingsState> {
  final GetAvailableTafsirs getAvailableTafsirs;
  final GetAvailableReciters getAvailableReciters;
  final SharedPreferences sharedPreferences;

  QuranSettingsCubit({
    required this.getAvailableTafsirs,
    required this.getAvailableReciters,
    required this.sharedPreferences,
  }) : super(QuranSettingsInitial());

  static const String kSelectedTafsirKey = 'selected_tafsir_id';
  static const String kSelectedReciterKey = 'selected_reciter_id';

  Future<void> loadSettings(String language) async {
    try {
      emit(QuranSettingsLoading());

      print('🔄 Loading Quran settings for language: $language');

      final tafsirsResult = await getAvailableTafsirs(language);
      final recitersResult = await getAvailableReciters(language);

      tafsirsResult.fold(
        (failure) {
          print('❌ Failed to load tafsirs: ${failure.message}');
          if (!isClosed) {
            emit(QuranSettingsError(failure.message));
          }
        },
        (tafsirs) {
          print('✅ Loaded ${tafsirs.length} tafsirs');
          recitersResult.fold(
            (failure) {
              print('❌ Failed to load reciters: ${failure.message}');
              if (!isClosed) {
                emit(QuranSettingsError(failure.message));
              }
            },
            (reciters) {
              print('✅ Loaded ${reciters.length} reciters');

              final savedTafsirId = sharedPreferences.getString(
                kSelectedTafsirKey,
              );
              final savedReciterId = sharedPreferences.getString(
                kSelectedReciterKey,
              );

              // Default logic if nothing saved
              final defaultTafsir = tafsirs.isNotEmpty
                  ? tafsirs.first.identifier
                  : '';
              final defaultReciter = reciters.isNotEmpty
                  ? reciters.first.identifier
                  : '';

              print('📖 Selected Tafsir: ${savedTafsirId ?? defaultTafsir}');
              print(
                '🎙️ Selected Reciter: ${savedReciterId ?? defaultReciter}',
              );

              if (!isClosed) {
                emit(
                  QuranSettingsLoaded(
                    availableTafsirs: tafsirs,
                    availableReciters: reciters,
                    selectedTafsirId: savedTafsirId ?? defaultTafsir,
                    selectedReciterId: savedReciterId ?? defaultReciter,
                  ),
                );
              }
            },
          );
        },
      );
    } catch (e, stackTrace) {
      print('❌ Unexpected error in loadSettings: $e');
      print('Stack trace: $stackTrace');
      if (!isClosed) {
        emit(QuranSettingsError('حدث خطأ غير متوقع: $e'));
      }
    }
  }

  Future<void> changeTafsir(String tafsirId) async {
    if (state is QuranSettingsLoaded) {
      await sharedPreferences.setString(kSelectedTafsirKey, tafsirId);
      emit((state as QuranSettingsLoaded).copyWith(selectedTafsirId: tafsirId));
    }
  }

  Future<void> changeReciter(String reciterId) async {
    if (state is QuranSettingsLoaded) {
      await sharedPreferences.setString(kSelectedReciterKey, reciterId);
      // ✅ مسح كل مفاتيح الكاش التي تبدأ بـ CACHED_SURAH_DETAILS_
      final keys = sharedPreferences.getKeys().toList();
      int clearedCount = 0;
      for (final key in keys) {
        if (key.startsWith('CACHED_SURAH_DETAILS_')) {
          await sharedPreferences.remove(key);
          clearedCount++;
        }
      }
      print(
        '🔄 Reciter changed to: $reciterId - Cleared $clearedCount surah caches',
      );
      emit(
        (state as QuranSettingsLoaded).copyWith(selectedReciterId: reciterId),
      );
    }
  }
}
