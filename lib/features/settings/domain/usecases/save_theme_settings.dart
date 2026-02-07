import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/settings/domain/entities/theme_settings.dart';
import 'package:meshkat_elhoda/features/settings/domain/repositories/theme_repository.dart';

class SaveThemeSettings {
  final ThemeRepository repository;

  SaveThemeSettings(this.repository);

  Future<Either<Failure, void>> call(ThemeSettings settings) async {
    return await repository.saveThemeSettings(settings);
  }
}

class SaveThemeMode {
  final ThemeRepository repository;

  SaveThemeMode(this.repository);

  Future<Either<Failure, void>> call(ThemeMode mode) async {
    return await repository.saveThemeMode(mode);
  }
}
