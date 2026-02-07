import 'dart:developer' as dev;
import 'package:meshkat_elhoda/core/network/firebase_service.dart';
import '../models/user_subscription_model.dart';

abstract class SubscriptionLocalDataSource {
  Future<UserSubscriptionModel> getSubscription();
  Future<void> saveSubscription(UserSubscriptionModel subscription);
}

class SubscriptionLocalDataSourceImpl implements SubscriptionLocalDataSource {
  final FirebaseService firebaseService;

  SubscriptionLocalDataSourceImpl({required this.firebaseService});

  @override
  Future<UserSubscriptionModel> getSubscription() async {
    try {
      final userId = firebaseService.currentUserId;
      if (userId == null) {
        dev.log('Subscription: No user logged in, returning free');
        return const UserSubscriptionModel(type: 'free', expireAt: null);
      }

      dev.log('Subscription: User ID: $userId');

      final userData = await firebaseService.getDocument('users', userId);

      if (userData.containsKey('subscription')) {
        final subscriptionData = userData['subscription'];

        // Print the type as requested
        dev.log('Subscription Data from DB: $subscriptionData');
        if (subscriptionData is Map) {
          dev.log('Subscription Type: ${subscriptionData['type']}');
          dev.log('Expires At: ${subscriptionData['expiresAt']}');
        }

        return UserSubscriptionModel.fromJson(
          Map<String, dynamic>.from(subscriptionData as Map),
        );
      }

      dev.log('Subscription: No subscription data found, returning free');
      return const UserSubscriptionModel(type: 'free', expireAt: null);
    } catch (e) {
      dev.log('Subscription Error: $e');
      return const UserSubscriptionModel(type: 'free', expireAt: null);
    }
  }

  @override
  Future<void> saveSubscription(UserSubscriptionModel subscription) async {
    try {
      final userId = firebaseService.currentUserId;
      if (userId == null) {
        dev.log('❌ Cannot save subscription: No user logged in');
        return;
      }

      await firebaseService.updateDocument('users', userId, {
        'subscription': {
          'type': subscription.type,
          'expiresAt': subscription.expireAt?.toIso8601String(),
        },
      });

      dev.log('✅ Subscription saved successfully');
    } catch (e) {
      dev.log('❌ Error saving subscription: $e');
      rethrow;
    }
  }
}
