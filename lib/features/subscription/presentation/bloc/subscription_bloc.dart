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
          isProductsLoading: false,
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
      // Show loading indicator in UI if already in Loaded state
      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(isProductsLoading: true));
      }

      // If products load too fast (before IAP is initialized), we might get empty results.
      List<ProductDetails> products = await repository.getProducts();
      
      // Retry up to 5 times (increased from 3) if empty
      int retries = 0;
      while (products.isEmpty && retries < 5) {
        await Future.delayed(const Duration(seconds: 1));
        products = await repository.getProducts();
        retries++;
      }

      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(products: products, isProductsLoading: false));
      } else {
        // Load subscription first if not loaded
        final subscription = await repository.getSubscription();
        final featureManager = FeatureManager(subscription);
        emit(
          SubscriptionLoaded(
            subscription: subscription,
            featureManager: featureManager,
            products: products,
            isProductsLoading: false,
          ),
        );
      }
    } catch (e) {
      log('❌ Error loading products: $e');
      if (state is SubscriptionLoaded) {
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(isProductsLoading: false));
      } else {
        emit(const SubscriptionError("Failed to load products"));
      }
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
      
      // Wait a short time to allow the purchase stream to emit any events
      await Future.delayed(const Duration(seconds: 2));
      
      // Reload products to reset the UI state to normal, ensuring the spinner stops
      add(LoadProductsEvent());
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
      } else if (purchase.status == PurchaseStatus.canceled) {
        log('❌ Purchase canceled');
        emit(const SubscriptionError("Purchase was canceled"));
        add(LoadProductsEvent());
      } else if (purchase.status == PurchaseStatus.error) {
        log('❌ Purchase error: ${purchase.error}');
        emit(
          SubscriptionError(
            "Purchase failed: ${purchase.error?.message ?? 'Unknown error'}",
          ),
        );
        add(LoadProductsEvent());
      }

      // Always complete failed/canceled purchases as well to remove them from the queue
      if (purchase.status == PurchaseStatus.error || purchase.status == PurchaseStatus.canceled) {
        if (purchase.pendingCompletePurchase) {
          try {
            await InAppPurchase.instance.completePurchase(purchase);
          } catch (e) {
            log('❌ Error completing failed purchase: $e');
          }
        }
      }
    }
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    return super.close();
  }
}
