import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/entities/feature_manager.dart';
import '../../domain/entities/user_subscription_entity.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final UserSubscriptionEntity subscription;
  final FeatureManager featureManager;
  final List<ProductDetails> products;
  final bool? _isProductsLoading;

  bool get isProductsLoading => _isProductsLoading ?? false;

  const SubscriptionLoaded({
    required this.subscription,
    required this.featureManager,
    this.products = const [],
    bool? isProductsLoading = false,
  }) : _isProductsLoading = isProductsLoading;

  @override
  List<Object> get props => [
        subscription,
        featureManager,
        products,
        isProductsLoading,
      ];

  SubscriptionLoaded copyWith({
    UserSubscriptionEntity? subscription,
    FeatureManager? featureManager,
    List<ProductDetails>? products,
    bool? isProductsLoading,
  }) {
    return SubscriptionLoaded(
      subscription: subscription ?? this.subscription,
      featureManager: featureManager ?? this.featureManager,
      products: products ?? this.products,
      isProductsLoading: isProductsLoading ?? _isProductsLoading,
    );
  }
}

class PurchaseProcessing extends SubscriptionState {
  final String message;

  const PurchaseProcessing(this.message);

  @override
  List<Object> get props => [message];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}
