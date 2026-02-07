import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/entities/feature_manager.dart';
import '../../domain/entities/user_subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';
import 'dart:developer';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository repository;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  SubscriptionBloc({required this.repository}) : super(SubscriptionInitial()) {
    on<LoadSubscriptionEvent>(_onLoadSubscription);
    on<LoadProductsEvent>(_onLoadProducts);
    on<BuySubscriptionEvent>(_onBuySubscription);
    on<RestorePurchasesEvent>(_onRestorePurchases);
    on<ProcessPurchaseEvent>(_onProcessPurchase);

    // Listen to purchase stream
    _purchaseSubscription = repository.purchaseStream.listen((purchases) {
      add(ProcessPurchaseEvent(purchases));
    });
  }

  Future<void> _onLoadSubscription(
    LoadSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final subscription = await repository.getSubscription();
      final featureManager = FeatureManager(subscription);
      emit(
        SubscriptionLoaded(
          subscription: subscription,
          featureManager: featureManager,
        ),
      );
    } catch (e) {
      emit(const SubscriptionError("Failed to load subscription"));
    }
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final products = await repository.getProducts();

      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(products: products));
      } else {
        // Load subscription first
        final subscription = await repository.getSubscription();
        final featureManager = FeatureManager(subscription);
        emit(
          SubscriptionLoaded(
            subscription: subscription,
            featureManager: featureManager,
            products: products,
          ),
        );
      }
    } catch (e) {
      log('❌ Error loading products: $e');
      emit(const SubscriptionError("Failed to load products"));
    }
  }

  Future<void> _onBuySubscription(
    BuySubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(const PurchaseProcessing("Processing purchase..."));
      await repository.buyProduct(event.product);
    } catch (e) {
      log('❌ Error buying subscription: $e');
      emit(const SubscriptionError("Failed to purchase subscription"));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(const PurchaseProcessing("Restoring purchases..."));
      await repository.restorePurchases();
    } catch (e) {
      log('❌ Error restoring purchases: $e');
      emit(const SubscriptionError("Failed to restore purchases"));
    }
  }

  Future<void> _onProcessPurchase(
    ProcessPurchaseEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    for (final purchase in event.purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Complete the purchase
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }

        // Calculate subscription type and expiry date based on product ID
        String subscriptionType = 'premium';
        DateTime expiryDate;

        // Check for monthly subscription (Android: monthly_subscription, iOS: monthly)
        if (purchase.productID == 'monthly_subscription' ||
            purchase.productID == 'monthly') {
          // Monthly subscription - expires in 1 month
          expiryDate = DateTime.now().add(Duration(days: 30));
          subscriptionType = 'monthly';
        }
        // Check for yearly subscription (Android: yearly_subscription, iOS: premium_yearly)
        else if (purchase.productID == 'yearly_subscription' ||
            purchase.productID == 'premium_yearly') {
          // Yearly subscription - expires in 1 year
          expiryDate = DateTime.now().add(Duration(days: 365));
          subscriptionType = 'yearly';
        } else {
          // Default to 1 month for unknown products
          expiryDate = DateTime.now().add(Duration(days: 30));
        }

        // Save subscription to Firebase
        try {
          final subscription = UserSubscriptionEntity(
            type: subscriptionType,
            expireAt: expiryDate,
          );

          await repository.saveSubscription(subscription);
          log(
            '✅ Subscription saved: $subscriptionType, expires: ${expiryDate.toIso8601String()}',
          );
        } catch (e) {
          log('❌ Error saving subscription: $e');
        }

        // Reload subscription to reflect changes
        add(LoadSubscriptionEvent());
      } else if (purchase.status == PurchaseStatus.error) {
        log('❌ Purchase error: ${purchase.error}');
        emit(
          SubscriptionError(
            "Purchase failed: ${purchase.error?.message ?? 'Unknown error'}",
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    return super.close();
  }
}
