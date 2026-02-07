import 'package:equatable/equatable.dart';

class Mosque extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [id, name, address, latitude, longitude];
}
