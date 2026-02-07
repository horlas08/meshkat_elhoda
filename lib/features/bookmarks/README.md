# Quran Bookmarks Feature

## Overview
A comprehensive bookmark system for the Quran reading app that allows users to save, manage, and navigate to their favorite verses using Firebase Firestore as the main data source with local caching via SharedPreferences.

## Architecture
The feature follows **Clean Architecture** principles with three main layers:

### 1. Domain Layer (`domain/`)
- **Entities**: `BookmarkEntity` - Core business model
- **Repositories**: `BookmarkRepository` - Abstract interface
- **Use Cases**:
  - `AddBookmark` - Add a new bookmark with optional note
  - `GetBookmarks` - Fetch all user bookmarks
  - `DeleteBookmark` - Remove a bookmark
  - `IsBookmarked` - Check if an ayah is bookmarked
  - `GetBookmarkId` - Get bookmark ID for a specific ayah

### 2. Data Layer (`data/`)
- **Models**: `BookmarkModel` - Data transfer object with Firestore serialization
- **Data Sources**:
  - `BookmarkRemoteDataSource` - Firebase Firestore operations
  - `BookmarkLocalDataSource` - SharedPreferences caching
- **Repository Implementation**: `BookmarkRepositoryImpl` - Implements domain repository with offline-first strategy

### 3. Presentation Layer (`presentation/`)
- **BLoC**: State management using flutter_bloc
  - `BookmarkBloc` - Business logic controller
  - `BookmarkEvent` - User actions
  - `BookmarkState` - UI states
- **Screens**: `BookmarksScreen` - Full-screen bookmark list
- **Widgets**: `AddBookmarkDialog` - Dialog for adding bookmarks with notes

## Features

### ✅ Add Bookmark
- Tap on any verse in the Quran reading screen
- Select "إضافة علامة مرجعية" (Add Bookmark)
- Optionally add a personal note
- Saved to Firestore under `users/{uid}/bookmarks/{bookmarkId}`

### ✅ View Bookmarks
- Access from three locations:
  1. Main app tab "المرجعيات" (Bookmarks)
  2. Bookmark icon in SurahScreen AppBar
  3. Dedicated BookmarksScreen
- Displays: Surah name, ayah number, verse text preview, optional note, creation date
- Sorted by creation date (newest first)

### ✅ Delete Bookmark
- Tap delete icon on any bookmark card
- Confirmation dialog before deletion
- Syncs with Firestore and updates cache

### ✅ Navigate to Bookmarked Verse
- Tap on any bookmark card
- Opens the Surah screen at the bookmarked location
- Preserves reading mode preferences

### ✅ Offline Support
- Bookmarks cached locally using SharedPreferences
- View cached bookmarks when offline
- Automatic sync when connection restored

## Data Structure

### Firestore Path
```
users/{uid}/bookmarks/{bookmarkId}
```

### Bookmark Document
```dart
{
  'surahNumber': int,        // Surah number (1-114)
  'surahName': String,       // Arabic surah name
  'ayahNumber': int,         // Ayah number within surah
  'ayahText': String,        // Full ayah text
  'createdAt': Timestamp,    // Creation timestamp
  'note': String?,           // Optional user note
}
```

## State Management

### BLoC Events
- `AddBookmarkEvent` - Add new bookmark
- `GetBookmarksEvent` - Fetch all bookmarks
- `DeleteBookmarkEvent` - Delete bookmark by ID
- `CheckBookmarkStatusEvent` - Check if ayah is bookmarked

### BLoC States
- `BookmarkInitial` - Initial state
- `BookmarkLoading` - Loading bookmarks
- `BookmarkActionLoading` - Processing add/delete
- `BookmarksLoaded` - Bookmarks fetched successfully
- `BookmarkAdded` - Bookmark added successfully
- `BookmarkDeleted` - Bookmark deleted successfully
- `BookmarkStatusChecked` - Bookmark status retrieved
- `BookmarkError` - Error occurred

## Integration Points

### 1. Service Locator (`core/service_locator.dart`)
All bookmark dependencies are registered:
```dart
// Data Sources
BookmarkLocalDataSource
BookmarkRemoteDataSource

// Repository
BookmarkRepository

// Use Cases
AddBookmark, GetBookmarks, DeleteBookmark, IsBookmarked, GetBookmarkId

// BLoC
BookmarkBloc
```

### 2. SurahScreen Integration
- Added bookmark option in ayah options dialog
- Bookmark icon in AppBar for quick access
- Shows add bookmark dialog with note input

### 3. QuranIndexView Integration
- Third tab displays bookmarks
- Inline bookmark cards with delete functionality
- Empty state when no bookmarks exist

## UI Components

### BookmarksScreen
- Full-screen bookmark list
- Pull-to-refresh support
- Error handling with retry
- Empty state illustration

### AddBookmarkDialog
- Clean modal dialog
- Optional note input with checkbox
- Surah and ayah information display
- Confirm/Cancel actions

### Bookmark Card
- Surah name and ayah number
- Truncated verse text preview
- Optional note display with amber background
- Delete button
- Relative timestamp (e.g., "منذ يومين")
- Tap to navigate to verse

## Error Handling

### Network Errors
- Graceful fallback to cached data
- User-friendly error messages
- Retry functionality

### Firestore Errors
- Authentication checks
- Permission validation
- Transaction error handling

### Cache Errors
- JSON serialization error handling
- Corrupted data recovery

## Theme Support
- Fully supports light and dark themes
- Consistent color scheme with app design
- Golden accent color (#D4A574)
- Responsive sizing using size_utils

## Dependencies Used
- `firebase_auth` - User authentication
- `cloud_firestore` - Remote data storage
- `shared_preferences` - Local caching
- `flutter_bloc` - State management
- `dartz` - Functional programming (Either)
- `equatable` - Value equality

## Future Enhancements
- [ ] Bookmark folders/categories
- [ ] Export bookmarks to file
- [ ] Share bookmarks with others
- [ ] Bookmark search functionality
- [ ] Bulk delete bookmarks
- [ ] Edit bookmark notes
- [ ] Bookmark statistics
- [ ] Cloud backup/restore

## Testing Checklist
- [ ] Add bookmark while online
- [ ] Add bookmark while offline (should fail gracefully)
- [ ] View bookmarks while online
- [ ] View bookmarks while offline (cached)
- [ ] Delete bookmark while online
- [ ] Delete bookmark while offline (should fail gracefully)
- [ ] Navigate to bookmarked verse
- [ ] Add bookmark with note
- [ ] Add bookmark without note
- [ ] Handle duplicate bookmarks
- [ ] Theme switching
- [ ] RTL layout support

## File Structure
```
lib/features/bookmarks/
├── data/
│   ├── datasources/
│   │   ├── bookmark_local_data_source.dart
│   │   └── bookmark_remote_data_source.dart
│   ├── models/
│   │   └── bookmark_model.dart
│   └── repositories/
│       └── bookmark_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── bookmark_entity.dart
│   ├── repositories/
│   │   └── bookmark_repository.dart
│   └── usecases/
│       ├── add_bookmark.dart
│       ├── delete_bookmark.dart
│       ├── get_bookmark_id.dart
│       ├── get_bookmarks.dart
│       └── is_bookmarked.dart
└── presentation/
    ├── bloc/
    │   ├── bookmark_bloc.dart
    │   ├── bookmark_event.dart
    │   └── bookmark_state.dart
    ├── screens/
    │   └── bookmarks_screen.dart
    └── widgets/
        └── add_bookmark_dialog.dart
```

## Notes
- User must be authenticated to use bookmarks
- Bookmarks are user-specific (isolated by UID)
- Firestore security rules should restrict access to user's own bookmarks
- Local cache is cleared on app uninstall
- Maximum ayah text preview: 100 characters
- Timestamps are relative (e.g., "منذ 3 أيام")

---
**Created**: October 2025  
**Status**: ✅ Production Ready  
**Architecture**: Clean Architecture + BLoC Pattern
