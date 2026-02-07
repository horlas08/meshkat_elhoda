import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/settings/data/datasources/theme_local_data_source.dart';
import 'package:meshkat_elhoda/features/settings/data/models/theme_settings_model.dart';
import 'package:meshkat_elhoda/features/settings/domain/entities/theme_settings.dart';
import 'package:meshkat_elhoda/features/settings/domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;

  ThemeRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ThemeSettings>> getThemeSettings() async {
    try {
      final settings = await localDataSource.getThemeSettings();
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get theme settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveThemeSettings(
    ThemeSettings settings,
  ) async {
    try {
      final model = ThemeSettingsModel.fromEntity(settings);
      await localDataSource.saveThemeSettings(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save theme settings: $e'));
    }
  }

  @override
  Future<Either<Failure, ThemeMode>> getThemeMode() async {
    try {
      final mode = await localDataSource.getThemeMode();
      return Right(mode);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get theme mode: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveThemeMode(ThemeMode mode) async {
    try {
      await localDataSource.saveThemeMode(mode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save theme mode: $e'));
    }
  }
}
