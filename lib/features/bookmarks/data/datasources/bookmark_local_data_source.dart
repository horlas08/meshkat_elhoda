import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_model.dart';

abstract class BookmarkLocalDataSource {
  Future<void> cacheBookmarks(List<BookmarkModel> bookmarks);
  Future<List<BookmarkModel>> getCachedBookmarks();
  Future<void> clearCache();
}

class BookmarkLocalDataSourceImpl implements BookmarkLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachedBookmarksKey = 'CACHED_BOOKMARKS';

  BookmarkLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheBookmarks(List<BookmarkModel> bookmarks) async {
    try {
      final jsonList = bookmarks.map((bookmark) => bookmark.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(_cachedBookmarksKey, jsonString);
    } catch (e) {
      throw Exception('Failed to cache bookmarks: $e');
    }
  }

  @override
  Future<List<BookmarkModel>> getCachedBookmarks() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedBookmarksKey);
      if (jsonString == null) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => BookmarkModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cached bookmarks: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_cachedBookmarksKey);
    } catch (e) {
      throw Exception('Failed to clear bookmark cache: $e');
    }
  }
}
