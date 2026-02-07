# Hadith Feature

This feature implements a complete Hadith module following Clean Architecture principles with BLoC state management.

## 📁 Structure

```
lib/features/hadith/
├── data/
│   ├── datasources/
│   │   ├── hadith_remote_data_source.dart    # Fetches from Hadith API
│   │   └── hadith_local_data_source.dart     # Local caching with SharedPreferences
│   ├── models/
│   │   └── hadith_model.dart                 # Data model with JSON serialization
│   └── repositories/
│       └── hadith_repository_impl.dart       # Repository implementation
│
├── domain/
│   ├── entities/
│   │   └── hadith.dart                       # Core domain entity
│   ├── repositories/
│   │   └── hadith_repository.dart            # Repository interface
│   └── usecases/
│       ├── get_random_hadith.dart            # Fetch random hadith
│       ├── get_hadith_by_id.dart             # Fetch specific hadith
│       └── get_all_hadiths.dart              # Fetch all hadiths
│
└── presentation/
    ├── bloc/
    │   ├── hadith_bloc.dart                  # BLoC logic
    │   ├── hadith_event.dart                 # Events
    │   └── hadith_state.dart                 # States
    ├── pages/
    │   ├── hadith_list_page.dart             # Main page with random hadith
    │   └── hadith_details_page.dart          # Detailed hadith view
    └── widgets/
        └── hadith_card.dart                  # Reusable hadith card widget
```

## ✅ Features Implemented

- **Clean Architecture**: Clear separation between data, domain, and presentation layers
- **BLoC Pattern**: State management with equatable for efficient comparisons
- **Remote Data Source**: Fetches from Hadith API (https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1)
- **Local Caching**: Offline support using SharedPreferences
- **Error Handling**: Either<Failure, Data> pattern for robust error handling
- **Dependency Injection**: All dependencies registered in service_locator.dart

## 🚀 Usage

### Navigate to Hadith Page

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const HadithListPage(),
  ),
);
```

### Features Available

1. **Random Hadith**: Displays a random hadith on page load
2. **Refresh**: Pull-to-refresh or tap "Get Another Hadith" button
3. **View All**: Tap the list icon to view first 50 hadiths
4. **Details**: Tap any hadith card to view full details
5. **Copy**: Copy hadith text to clipboard from details page
6. **Offline Support**: Automatically uses cached data when offline

## 🔧 API Details

- **Base URL**: `https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions`
- **Edition**: `ara-bukhari` (Arabic Sahih Bukhari)
- **Fallback**: Automatically tries `.min.json` if `.json` fails
- **Total Hadiths**: 7563 hadiths in Bukhari collection

## 📦 Dependencies

All required dependencies are already in your `pubspec.yaml`:
- `flutter_bloc`: State management
- `equatable`: Value equality
- `http`: API calls
- `shared_preferences`: Local storage
- `dartz`: Functional programming (Either type)
- `get_it`: Dependency injection

## 🔌 Dependency Injection

All dependencies are registered in `lib/core/services/service_locator.dart`:

- Data sources (remote & local)
- Repository implementation
- Use cases (GetRandomHadith, GetHadithById, GetAllHadiths)
- HadithBloc (factory registration)

## 🎨 UI Components

### HadithListPage
- Displays random hadith with refresh capability
- Toggle between single random hadith and list of all hadiths
- Loading states and error handling

### HadithDetailsPage
- Full hadith text display
- Book name, chapter, narrator, and reference
- Copy to clipboard functionality
- Share button (placeholder for future implementation)

### HadithCard
- Reusable card widget
- Displays hadith summary
- Tap to view details

## 📝 Notes

- The feature uses Arabic Sahih Bukhari edition by default
- First 50 hadiths are fetched for "View All" to optimize performance
- Offline caching ensures the app works without internet
- All code includes helpful English comments
- Follows null safety and clean code conventions
