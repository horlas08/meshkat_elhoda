import 'package:meshkat_elhoda/features/hajj_umrah/data/datasources/hajj_umrah_local_data_source.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/domain/entities/guide_step.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/domain/repositories/hajj_umrah_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HajjUmrahRepositoryImpl implements HajjUmrahRepository {
  final HajjUmrahLocalDataSource localDataSource;
  final SharedPreferences sharedPreferences;

  HajjUmrahRepositoryImpl({
    required this.localDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<List<GuideStep>> getUmrahSteps() async {
    return await localDataSource.getUmrahSteps();
  }

  @override
  Future<List<GuideStep>> getHajjSteps() async {
    return await localDataSource.getHajjSteps();
  }

  @override
  Future<void> saveProgress(String type, String stepId) async {
    await sharedPreferences.setString('hajj_umrah_progress_$type', stepId);
  }

  @override
  Future<String?> getProgress(String type) async {
    return sharedPreferences.getString('hajj_umrah_progress_$type');
  }
}
