import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';

abstract class AssistantLocalDataSource {
  Future<String?> getLastChatId();
  Future<void> saveLastChatId(String chatId);
  Future<String> getSelectedModel();
  Future<void> saveSelectedModel(String model);
  Future<int> getDailyQuestionCount();
  Future<void> incrementDailyQuestionCount();
  Future<void> resetDailyQuestionCount();
  Future<String?> getLastQuestionDate();
}

class AssistantLocalDataSourceImpl implements AssistantLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String lastChatIdKey = 'LAST_CHAT_ID';
  static const String selectedModelKey = 'SELECTED_MODEL';
  static const String dailyQuestionCountKey = 'DAILY_QUESTION_COUNT';
  static const String lastQuestionDateKey = 'LAST_QUESTION_DATE';

  AssistantLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String?> getLastChatId() async {
    try {
      return sharedPreferences.getString(lastChatIdKey);
    } catch (e) {
      throw const CacheException(message: 'Failed to get last chat ID');
    }
  }

  @override
  Future<void> saveLastChatId(String chatId) async {
    try {
      await sharedPreferences.setString(lastChatIdKey, chatId);
    } catch (e) {
      throw const CacheException(message: 'Failed to save last chat ID');
    }
  }

  @override
  Future<String> getSelectedModel() async {
    try {
      return sharedPreferences.getString(selectedModelKey) ?? 'gpt-4o-mini';
    } catch (e) {
      throw const CacheException(message: 'Failed to get selected model');
    }
  }

  @override
  Future<void> saveSelectedModel(String model) async {
    try {
      await sharedPreferences.setString(selectedModelKey, model);
    } catch (e) {
      throw const CacheException(message: 'Failed to save selected model');
    }
  }

  @override
  Future<int> getDailyQuestionCount() async {
    try {
      final lastDate = await getLastQuestionDate();
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Reset count if it's a new day
      if (lastDate != today) {
        await resetDailyQuestionCount();
        return 0;
      }

      return sharedPreferences.getInt(dailyQuestionCountKey) ?? 0;
    } catch (e) {
      throw const CacheException(message: 'Failed to get daily question count');
    }
  }

  @override
  Future<void> incrementDailyQuestionCount() async {
    try {
      final currentCount = await getDailyQuestionCount();
      final today = DateTime.now().toIso8601String().split('T')[0];

      await sharedPreferences.setInt(dailyQuestionCountKey, currentCount + 1);
      await sharedPreferences.setString(lastQuestionDateKey, today);
    } catch (e) {
      throw const CacheException(message: 'Failed to increment question count');
    }
  }

  @override
  Future<void> resetDailyQuestionCount() async {
    try {
      await sharedPreferences.setInt(dailyQuestionCountKey, 0);
      final today = DateTime.now().toIso8601String().split('T')[0];
      await sharedPreferences.setString(lastQuestionDateKey, today);
    } catch (e) {
      throw const CacheException(message: 'Failed to reset question count');
    }
  }

  @override
  Future<String?> getLastQuestionDate() async {
    try {
      return sharedPreferences.getString(lastQuestionDateKey);
    } catch (e) {
      throw const CacheException(message: 'Failed to get last question date');
    }
  }
}
