import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class LoadSubscriptionEvent extends SubscriptionEvent {}

class LoadProductsEvent extends SubscriptionEvent {}

class BuySubscriptionEvent extends SubscriptionEvent {
  final ProductDetails product;

  const BuySubscriptionEvent(this.product);

  @override
  List<Object> get props => [product];
}

class RestorePurchasesEvent extends SubscriptionEvent {}

class ProcessPurchaseEvent extends SubscriptionEvent {
  final List<PurchaseDetails> purchases;

  const ProcessPurchaseEvent(this.purchases);

  @override
  List<Object> get props => [purchases];
}
