import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/settings/domain/entities/theme_settings.dart';
import 'package:meshkat_elhoda/features/settings/domain/repositories/theme_repository.dart';

class GetThemeSettings {
  final ThemeRepository repository;

  GetThemeSettings(this.repository);

  Future<Either<Failure, ThemeSettings>> call() async {
    return await repository.getThemeSettings();
  }
}
