// في ملف user_entity.dart
import 'package:meshkat_elhoda/features/location/data/models/location_model.dart';

class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String language;
  final String country;
  final String city; // ← أضف هذا الحقل
  final LocationModel? location; // ← أضف بيانات الموقع الكاملة
  final SubscriptionEntity subscription;
  final DateTime createdAt;
  final String? deviceToken;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.language,
    required this.country,
    required this.city, // ← أضف هنا
    this.location, // ← أضف هنا
    required this.subscription,
    required this.createdAt,
    this.deviceToken,
  });

  // يمكنك إضافة دوال مساعدة إذا احتجت
  bool get hasExactLocation =>
      location != null &&
      location!.latitude != null &&
      location!.longitude != null;

  String get displayLocation {
    if (city.isNotEmpty && country.isNotEmpty) {
      return '$city, $country';
    } else if (country.isNotEmpty) {
      return country;
    } else {
      return 'موقع غير محدد';
    }
  }
}

class SubscriptionEntity {
  final String type;
  final DateTime? expiresAt;

  SubscriptionEntity({required this.type, this.expiresAt});

  Map<String, dynamic> toJson() {
    return {'type': type, 'expiresAt': expiresAt?.toIso8601String()};
  }
}
