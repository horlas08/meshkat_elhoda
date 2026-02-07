import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:developer';

class InAppPurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs - Different for Android and iOS
  // Android: monthly_subscription, yearly_subscription
  // iOS: monthly, premium_yearly
  static String get monthlySubscriptionId =>
      Platform.isIOS ? 'monthly' : 'monthly_subscription';
  static String get yearlySubscriptionId =>
      Platform.isIOS ? 'premium_yearly' : 'yearly_subscription';

  Set<String> get _kIds => {monthlySubscriptionId, yearlySubscriptionId};

  // Stream to notify app about purchase updates
  final _purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _purchaseController.stream;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      log('❌ InAppPurchase store not available');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      (purchaseDetailsList) {
        _purchaseController.add(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        log('❌ Error in purchase stream: $error');
      },
    );

    log('✅ InAppPurchaseService initialized');
  }

  Future<List<ProductDetails>> getProducts() async {
    if (!_isAvailable) return [];

    final ProductDetailsResponse response = await _iap.queryProductDetails(
      _kIds,
    );
    if (response.error != null) {
      log('❌ Error querying products: ${response.error}');
      return [];
    }

    if (response.productDetails.isEmpty) {
      log(
        '⚠️ No products found. Make sure they are defined in the store console.',
      );
    }

    return response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    if (!_isAvailable) return;

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}
