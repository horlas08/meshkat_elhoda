import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/features/settings/domain/entities/theme_settings.dart';

class ThemeSettingsModel extends ThemeSettings {
  const ThemeSettingsModel({
    required super.themeMode,
    required super.useSystemTheme,
  });

  factory ThemeSettingsModel.fromJson(Map<String, dynamic> json) {
    return ThemeSettingsModel(
      themeMode: _themeModeFromString(json['themeMode'] as String? ?? 'system'),
      useSystemTheme: json['useSystemTheme'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'themeMode': themeMode.name, 'useSystemTheme': useSystemTheme};
  }

  static ThemeMode _themeModeFromString(String mode) {
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

  factory ThemeSettingsModel.fromEntity(ThemeSettings entity) {
    return ThemeSettingsModel(
      themeMode: entity.themeMode,
      useSystemTheme: entity.useSystemTheme,
    );
  }
}
