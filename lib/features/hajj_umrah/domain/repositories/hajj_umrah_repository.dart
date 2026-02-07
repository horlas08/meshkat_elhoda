import 'package:meshkat_elhoda/features/hajj_umrah/domain/entities/guide_step.dart';

abstract class HajjUmrahRepository {
  Future<List<GuideStep>> getUmrahSteps();
  Future<List<GuideStep>> getHajjSteps();
  Future<void> saveProgress(String type, String stepId);
  Future<String?> getProgress(String type);
}
