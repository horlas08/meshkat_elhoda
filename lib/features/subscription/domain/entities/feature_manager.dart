import 'app_feature.dart';
import 'user_subscription_entity.dart';

class FeatureManager {
  final UserSubscriptionEntity subscription;

  FeatureManager(this.subscription);

  bool get _isPremium => subscription.isPremium;

  // Feature Getters
  bool get canUseAllTranslations => _isPremium;
  bool get canUseAdvancedTafseer => _isPremium;
  bool get canUseOfflineAudio => _isPremium;
  bool get canUseMultipleReaders => _isPremium;
  bool get canAccessRamadanMode => _isPremium;
  bool get canUseAIUnlimited => _isPremium;
  bool get canRemoveAds => _isPremium;
  bool get canAccessAllHadithBooks => _isPremium;

  // Special logic for free users
  bool get canUseFreeAIDailyLimit => true; // Everyone can use this

  int get maxDailyQuestions => _isPremium ? 1000 : 3;

  bool isAllowed(AppFeature feature) {
    switch (feature) {
      case AppFeature.advancedTranslations:
        return canUseAllTranslations;
      case AppFeature.advancedTafseer:
        return canUseAdvancedTafseer;
      case AppFeature.offlineAudio:
        return canUseOfflineAudio;
      case AppFeature.multipleReaders:
        return canUseMultipleReaders;
      case AppFeature.aiUnlimited:
        return canUseAIUnlimited;
      case AppFeature.ramadanMode:
        return canAccessRamadanMode;
      case AppFeature.noAds:
        return canRemoveAds;
      case AppFeature.allHadithBooks:
        return canAccessAllHadithBooks;
    }
  }
}
