import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/settings/domain/entities/theme_settings.dart';

abstract class ThemeRepository {
  Future<Either<Failure, ThemeSettings>> getThemeSettings();
  Future<Either<Failure, void>> saveThemeSettings(ThemeSettings settings);
  Future<Either<Failure, ThemeMode>> getThemeMode();
  Future<Either<Failure, void>> saveThemeMode(ThemeMode mode);
}
