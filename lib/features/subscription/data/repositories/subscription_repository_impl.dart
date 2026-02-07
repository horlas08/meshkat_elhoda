import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/entities/user_subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_data_source.dart';
import '../models/user_subscription_model.dart';
import 'package:meshkat_elhoda/core/services/in_app_purchase_service.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource localDataSource;
  final InAppPurchaseService iapService;

  SubscriptionRepositoryImpl({
    required this.localDataSource,
    required this.iapService,
  });

  @override
  Future<UserSubscriptionEntity> getSubscription() async {
    try {
      final model = await localDataSource.getSubscription();
      return model;
    } catch (e) {
      // In case of error, return default free subscription
      return const UserSubscriptionEntity(type: 'free');
    }
  }

  @override
  Future<void> saveSubscription(UserSubscriptionEntity subscription) async {
    final model = UserSubscriptionModel(
      type: subscription.type,
      expireAt: subscription.expireAt,
    );
    await localDataSource.saveSubscription(model);
  }

  @override
  Future<List<ProductDetails>> getProducts() => iapService.getProducts();

  @override
  Future<void> buyProduct(ProductDetails product) =>
      iapService.buyProduct(product);

  @override
  Future<void> restorePurchases() => iapService.restorePurchases();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => iapService.purchaseStream;
}
