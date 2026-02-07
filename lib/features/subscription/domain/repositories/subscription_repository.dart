import 'package:in_app_purchase/in_app_purchase.dart';
import '../entities/user_subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<UserSubscriptionEntity> getSubscription();
  Future<void> saveSubscription(UserSubscriptionEntity subscription);
  Future<List<ProductDetails>> getProducts();
  Future<void> buyProduct(ProductDetails product);
  Future<void> restorePurchases();
  Stream<List<PurchaseDetails>> get purchaseStream;
}
