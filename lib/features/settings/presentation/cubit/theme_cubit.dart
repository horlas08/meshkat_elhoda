import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/settings/domain/usecases/get_theme_settings.dart';
import 'package:meshkat_elhoda/features/settings/domain/usecases/save_theme_settings.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final GetThemeSettings getThemeSettings;
  final SaveThemeMode saveThemeMode;

  ThemeCubit({required this.getThemeSettings, required this.saveThemeMode})
    : super(ThemeMode.system);

  /// تحميل الثيم المحفوظ
  Future<void> loadTheme() async {
    final result = await getThemeSettings();
    result.fold(
      (failure) {
        print('❌ Failed to load theme: ${failure.message}');
        emit(ThemeMode.system);
      },
      (settings) {
        print('✅ Loaded theme: ${settings.themeMode.name}');
        emit(settings.themeMode);
      },
    );
  }

  /// تبديل بين Light و Dark
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    await setTheme(newMode);
  }

  /// تعيين ثيم محدد
  Future<void> setTheme(ThemeMode mode) async {
    print('🎨 Setting theme to: ${mode.name}');

    final result = await saveThemeMode(mode);
    result.fold(
      (failure) {
        print('❌ Failed to save theme: ${failure.message}');
      },
      (_) {
        print('✅ Theme saved successfully');
        emit(mode);
      },
    );
  }

  /// تعيين الثيم حسب النظام
  Future<void> useSystemTheme() async {
    await setTheme(ThemeMode.system);
  }
}
