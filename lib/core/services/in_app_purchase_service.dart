import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:developer';

class InAppPurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  static const String monthlySubscriptionId = 'monthly_subscription';
  static const String yearlySubscriptionId = 'yearly_subscription';
  static const String legacyIosMonthlySubscriptionId = 'monthly';
  static const String legacyIosYearlySubscriptionId = 'premium_yearly';

  Set<String> get _kIds => Platform.isIOS
      ? {
          monthlySubscriptionId,
          yearlySubscriptionId,
          legacyIosMonthlySubscriptionId,
          legacyIosYearlySubscriptionId,
        }
      : {monthlySubscriptionId, yearlySubscriptionId};

  // Stream to notify app about purchase updates
  final _purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _purchaseController.stream;

  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get ready => _initCompleter.future;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        log('❌ InAppPurchase store not available');
        _initCompleter.complete();
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
    } catch (e) {
      log('❌ InAppPurchaseService initialization failed: $e');
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  Future<List<ProductDetails>> getProducts() async {
    await ready;
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
    await ready;
    if (!_isAvailable) return;

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await ready;
    if (!_isAvailable) return;
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}
