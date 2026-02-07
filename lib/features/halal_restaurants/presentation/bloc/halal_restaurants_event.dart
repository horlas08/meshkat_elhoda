import 'package:equatable/equatable.dart';

abstract class HalalRestaurantsEvent extends Equatable {
  const HalalRestaurantsEvent();

  @override
  List<Object?> get props => [];
}

class GetNearbyHalalRestaurantsEvent extends HalalRestaurantsEvent {
  const GetNearbyHalalRestaurantsEvent();
}
