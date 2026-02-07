import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int userRatingsTotal;

  const Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating = 0.0,
    this.userRatingsTotal = 0,
  });

  @override
  List<Object?> get props =>
      [id, name, address, latitude, longitude, rating, userRatingsTotal];
}
