import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/domain/entities/restaurant.dart';

abstract class HalalRestaurantsState extends Equatable {
  const HalalRestaurantsState();

  @override
  List<Object?> get props => [];
}

class HalalRestaurantsInitial extends HalalRestaurantsState {
  const HalalRestaurantsInitial();
}

class HalalRestaurantsLoading extends HalalRestaurantsState {
  const HalalRestaurantsLoading();
}

class HalalRestaurantsLoaded extends HalalRestaurantsState {
  final List<Restaurant> restaurants;
  final double userLatitude;
  final double userLongitude;

  const HalalRestaurantsLoaded({
    required this.restaurants,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  List<Object?> get props => [restaurants, userLatitude, userLongitude];
}

class HalalRestaurantsError extends HalalRestaurantsState {
  final String message;
  const HalalRestaurantsError(this.message);

  @override
  List<Object?> get props => [message];
}
