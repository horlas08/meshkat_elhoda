# Quran Tafsir and Reciter Selection Feature - Implementation Summary

## Overview
This document summarizes the implementation of the Quran Tafsir and Reciter selection feature, which allows users to choose from multiple available Tafsir (Quranic exegesis) options and Reciter voices for verse-by-verse audio playback.

## Implementation Date
2025-11-29

## Features Implemented

### 1. Dynamic Tafsir Selection
- Users can now select from all available Tafsir editions for their preferred language
- Tafsir selection is saved and persisted across app sessions
- The selected Tafsir is automatically used when viewing verse explanations

### 2. Dynamic Reciter Selection
- Users can choose from all available Reciters for their preferred language
- Reciter selection is saved and persisted across app sessions
- The selected Reciter's audio is used for verse-by-verse playback

### 3. Quran Settings UI
- New "Quran Settings" section added to the Settings page
- Displays current selected Tafsir and Reciter
- Provides dialogs for easy selection of preferred options

## Technical Implementation

### A. Data Layer

#### 1. New Entity: `QuranEditionEntity`
**File:** `lib/features/quran_index/domain/entities/quran_edition_entity.dart`

```dart
class QuranEditionEntity {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;
  final String? direction;
}
```

#### 2. New Model: `QuranEditionModel`
**File:** `lib/features/quran_index/data/models/quran_edition_model.dart`

Implements `QuranEditionEntity` with JSON serialization for API responses.

#### 3. Updated `QuranRemoteDataSource`
**File:** `lib/features/quran_index/data/datasources/quran_remote_data_source.dart`

**New Methods:**
- `getAvailableTafsirs(String language)` - Fetches all Tafsir editions for a language
- `getAvailableReciters(String language)` - Fetches all Reciter editions for a language

**Updated Methods:**
- `getSurahByNumber(int number, {String? reciterId})` - Now accepts optional reciter ID
- `getAyahTafsir(int surahNumber, int ayahNumber, {String? tafsirId})` - Now accepts optional Tafsir ID

**Default Fallbacks:**
- Uses `defaultTafsirs` map if no Tafsir ID is provided
- Uses `defaultReciters` map if no Reciter ID is provided

#### 4. Updated `QuranRepository`
**File:** `lib/features/quran_index/domain/repositories/quran_repository.dart`

Added new methods:
```dart
Future<Either<Failure, List<QuranEditionEntity>>> getAvailableTafsirs(String language);
Future<Either<Failure, List<QuranEditionEntity>>> getAvailableReciters(String language);
```

Updated existing methods to accept optional IDs.

#### 5. Updated `QuranRepositoryImpl`
**File:** `lib/features/quran_index/data/repositories/quran_repository_impl.dart`

Implemented the new methods and updated existing ones to pass optional IDs to the data source.

### B. Domain Layer

#### 1. New Use Cases

**`GetAvailableTafsirs`**
**File:** `lib/features/quran_index/domain/usecases/get_available_tafsirs.dart`

```dart
class GetAvailableTafsirs {
  final QuranRepository repository;
  
  Future<Either<Failure, List<QuranEditionEntity>>> call(String language) async {
    return await repository.getAvailableTafsirs(language);
  }
}
```

**`GetAvailableReciters`**
**File:** `lib/features/quran_index/domain/usecases/get_available_reciters.dart`

Similar structure to `GetAvailableTafsirs`.

#### 2. Updated Use Cases

**`GetSurahByNumber`**
- Now accepts optional `reciterId` parameter

**`GetAyahTafsir`**
- Now accepts optional `tafsirId` parameter

### C. Presentation Layer - State Management

#### 1. New Cubit: `QuranSettingsCubit`
**File:** `lib/features/quran_index/presentation/bloc/quran_settings_cubit.dart`

**Responsibilities:**
- Load available Tafsirs and Reciters for a given language
- Manage selected Tafsir and Reciter IDs
- Persist selections to `SharedPreferences`

**Key Methods:**
- `loadSettings(String language)` - Fetches available options and loads saved preferences
- `changeTafsir(String tafsirId)` - Updates selected Tafsir
- `changeReciter(String reciterId)` - Updates selected Reciter

**SharedPreferences Keys:**
- `selected_tafsir_id` - Stores the selected Tafsir identifier
- `selected_reciter_id` - Stores the selected Reciter identifier

#### 2. New State: `QuranSettingsState`
**File:** `lib/features/quran_index/presentation/bloc/quran_settings_state.dart`

**States:**
- `QuranSettingsInitial`
- `QuranSettingsLoading`
- `QuranSettingsLoaded` - Contains available options and current selections
- `QuranSettingsError`

#### 3. Updated `QuranBloc`
**File:** `lib/features/quran_index/presentation/bloc/quran_bloc.dart`

Updated event handlers to pass optional IDs to use cases:
- `_onGetSurahByNumber` - Passes `reciterId` from event
- `_onGetAyahTafsir` - Passes `tafsirId` from event

#### 4. Updated `QuranEvent`
**File:** `lib/features/quran_index/presentation/bloc/quran_event.dart`

**Updated Events:**
- `GetSurahByNumberEvent` - Added optional `reciterId` field
- `GetAyahTafsirEvent` - Added optional `tafsirId` field

### D. Presentation Layer - UI

#### 1. New Widget: `QuranSettings`
**File:** `lib/features/settings/presentation/widgets/quran_settings.dart`

**Features:**
- Displays current selected Tafsir and Reciter
- Shows selection dialogs with all available options
- Automatically loads settings based on user's language preference
- Uses `BlocProvider` to manage `QuranSettingsCubit`

**UI Components:**
- `ExpansionTile` for collapsible settings section
- `SettingItem` widgets for Tafsir and Reciter selection
- `RadioListTile` in dialogs for option selection

#### 2. Updated `SettingView`
**File:** `lib/features/settings/presentation/views/setting_view.dart`

Added `QuranSettings()` widget to the settings page.

#### 3. Updated `SurahScreen`
**File:** `lib/features/quran_index/presentation/screens/surah_screen.dart`

**Changes:**
- Reads selected Reciter ID from `SharedPreferences` on initialization
- Passes Reciter ID to `GetSurahByNumberEvent`
- This ensures the correct Reciter's audio is loaded for all verses

```dart
create: (_) {
  final prefs = getIt<SharedPreferences>();
  final reciterId = prefs.getString('selected_reciter_id');
  return getIt<QuranBloc>()
    ..add(GetSurahByNumberEvent(
      number: widget.surahNumber,
      reciterId: reciterId,
    ));
}
```

#### 4. Updated `TafsirDialog`
**File:** `lib/features/quran_index/presentation/widgets/tafsier_dialog.dart`

**Changes:**
- Reads selected Tafsir ID from `SharedPreferences`
- Passes Tafsir ID to `GetAyahTafsirEvent`
- Displays the selected Tafsir when user taps on a verse

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  final prefs = getIt<SharedPreferences>();
  final tafsirId = prefs.getString('selected_tafsir_id');
  context.read<QuranBloc>().add(
    GetAyahTafsirEvent(
      surahNumber: widget.surahNumber,
      ayahNumber: widget.ayahNumber,
      language: 'ar',
      tafsirId: tafsirId,
    ),
  );
});
```

### E. Dependency Injection

#### Updated `ServiceLocator`
**File:** `lib/core/services/service_locator.dart`

**Registered:**
- `GetAvailableTafsirs` use case
- `GetAvailableReciters` use case
- `QuranSettingsCubit` factory

## API Integration

### Alquran.cloud API Endpoints Used

1. **Get Available Tafsirs:**
   ```
   GET https://api.alquran.cloud/v1/edition?format=text&language={language}&type=tafsir
   ```

2. **Get Available Reciters:**
   ```
   GET https://api.alquran.cloud/v1/edition?format=audio&language={language}&type=versebyverse
   ```

3. **Get Surah with Reciter:**
   ```
   GET https://api.alquran.cloud/v1/surah/{number}/{reciterId}
   ```

4. **Get Ayah Tafsir:**
   ```
   GET https://api.alquran.cloud/v1/ayah/{surahNumber}:{ayahNumber}/{tafsirId}
   ```

## User Flow

### Selecting a Tafsir
1. User opens Settings
2. Expands "Quran Settings" section
3. Taps on "التفسير المفضل" (Preferred Tafsir)
4. Dialog shows all available Tafsirs for their language
5. User selects a Tafsir
6. Selection is saved to SharedPreferences
7. Next time user views verse explanation, selected Tafsir is used

### Selecting a Reciter
1. User opens Settings
2. Expands "Quran Settings" section
3. Taps on "القارئ المفضل" (Preferred Reciter)
4. Dialog shows all available Reciters for their language
5. User selects a Reciter
6. Selection is saved to SharedPreferences
7. Next time user plays Quran audio, selected Reciter's voice is used

## Data Persistence

### SharedPreferences Keys
- `selected_tafsir_id`: Stores the identifier of the selected Tafsir (e.g., "ar.muyassar")
- `selected_reciter_id`: Stores the identifier of the selected Reciter (e.g., "ar.alafasy")

### Default Behavior
- If no selection is saved, the app uses language-specific defaults from `defaultTafsirs` and `defaultReciters` maps
- If the language doesn't have a default, it falls back to a global default

## Files Created

1. `lib/features/quran_index/domain/entities/quran_edition_entity.dart`
2. `lib/features/quran_index/data/models/quran_edition_model.dart`
3. `lib/features/quran_index/domain/usecases/get_available_tafsirs.dart`
4. `lib/features/quran_index/domain/usecases/get_available_reciters.dart`
5. `lib/features/quran_index/presentation/bloc/quran_settings_cubit.dart`
6. `lib/features/quran_index/presentation/bloc/quran_settings_state.dart`
7. `lib/features/settings/presentation/widgets/quran_settings.dart`

## Files Modified

1. `lib/features/quran_index/data/datasources/quran_remote_data_source.dart`
2. `lib/features/quran_index/domain/repositories/quran_repository.dart`
3. `lib/features/quran_index/data/repositories/quran_repository_impl.dart`
4. `lib/features/quran_index/domain/usecases/get_surah_by_number.dart`
5. `lib/features/quran_index/domain/usecases/get_ayah_tafsir.dart`
6. `lib/features/quran_index/presentation/bloc/quran_bloc.dart`
7. `lib/features/quran_index/presentation/bloc/quran_event.dart`
8. `lib/features/settings/presentation/views/setting_view.dart`
9. `lib/features/quran_index/presentation/screens/surah_screen.dart`
10. `lib/features/quran_index/presentation/widgets/tafsier_dialog.dart`
11. `lib/core/services/service_locator.dart`

## Testing Recommendations

1. **Test Tafsir Selection:**
   - Select different Tafsirs and verify they display correctly
   - Test with different languages
   - Verify persistence across app restarts

2. **Test Reciter Selection:**
   - Select different Reciters and verify audio plays correctly
   - Test with different languages
   - Verify persistence across app restarts

3. **Test Default Behavior:**
   - Clear SharedPreferences and verify defaults are used
   - Test with languages that have and don't have specific defaults

4. **Test Error Handling:**
   - Test with no internet connection
   - Test with invalid IDs
   - Verify error states display correctly

## Future Enhancements

1. **Favorites:** Allow users to favorite specific Tafsirs/Reciters for quick access
2. **Preview:** Add preview functionality to listen to Reciter samples before selection
3. **Offline Support:** Cache available editions for offline access
4. **Per-Surah Settings:** Allow different Reciters for different Surahs
5. **Comparison Mode:** Display multiple Tafsirs side-by-side

## Notes

- The implementation follows Clean Architecture principles
- All state management uses BLoC pattern
- API calls are properly abstracted through repositories
- User preferences are persisted using SharedPreferences
- The UI is fully localized and supports RTL languages
- Error handling is implemented at all layers

## Conclusion

This implementation provides users with full flexibility in choosing their preferred Tafsir and Reciter, enhancing the Quran reading and listening experience. The architecture is scalable and can easily accommodate future enhancements.
