import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/settings/data/models/theme_settings_model.dart';

abstract class ThemeLocalDataSource {
  Future<ThemeSettingsModel> getThemeSettings();
  Future<void> saveThemeSettings(ThemeSettingsModel settings);
  Future<ThemeMode> getThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _themeSettingsKey = 'THEME_SETTINGS';
  static const String _themeModeKey = 'THEME_MODE';

  ThemeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ThemeSettingsModel> getThemeSettings() async {
    // First check if we have a saved theme mode directly
    final modeString = sharedPreferences.getString(_themeModeKey);
    if (modeString != null) {
      final mode = _themeModeFromString(modeString);
      return ThemeSettingsModel(
        themeMode: mode,
        useSystemTheme: mode == ThemeMode.system,
      );
    }

    // Then check for full settings object
    final jsonString = sharedPreferences.getString(_themeSettingsKey);

    if (jsonString != null) {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return ThemeSettingsModel.fromJson(jsonMap);
    }

    // Default settings
    return const ThemeSettingsModel(
      themeMode: ThemeMode.system,
      useSystemTheme: true,
    );
  }

  @override
  Future<void> saveThemeSettings(ThemeSettingsModel settings) async {
    final jsonString = json.encode(settings.toJson());
    await sharedPreferences.setString(_themeSettingsKey, jsonString);
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final modeString = sharedPreferences.getString(_themeModeKey);

    if (modeString != null) {
      return _themeModeFromString(modeString);
    }

    return ThemeMode.system;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await sharedPreferences.setString(_themeModeKey, mode.name);
  }

  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
