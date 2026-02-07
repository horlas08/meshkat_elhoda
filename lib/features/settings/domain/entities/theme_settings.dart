import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeSettings extends Equatable {
  final ThemeMode themeMode;
  final bool useSystemTheme;

  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.useSystemTheme = true,
  });

  ThemeSettings copyWith({ThemeMode? themeMode, bool? useSystemTheme}) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
    );
  }

  @override
  List<Object?> get props => [themeMode, useSystemTheme];
}
