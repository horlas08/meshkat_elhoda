import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meshkat_elhoda/features/auth/domain/entities/user_entity.dart';
import 'package:meshkat_elhoda/features/location/data/models/location_model.dart';

class UserModel extends UserEntity {
  UserModel({
    required String uid,
    required String name,
    required String email,
    required String language,
    required String country,
    required String city, // ← مطلوب الآن
    LocationModel? location, // ← بيانات الموقع الكاملة
    required SubscriptionEntity subscription,
    required DateTime createdAt,
    String? deviceToken,
  }) : super(
         uid: uid,
         name: name,
         email: email,
         language: language,
         country: country,
         city: city, // ← أضف هنا
         location: location, // ← أضف هنا
         subscription: subscription,
         createdAt: createdAt,
         deviceToken: deviceToken,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      language: json['language'] as String,
      country: json['country'] as String,
      city: json['city'] as String, // ← أضف هنا
      location: json['location'] != null
          ? LocationModel.fromJson(
              Map<String, dynamic>.from(json['location'] as Map),
            )
          : null, // ← أضف هنا
      subscription: SubscriptionEntity(
        type: json['subscription']['type'] as String,
        expiresAt: json['subscription']['expiresAt'] != null
            ? DateTime.parse(json['subscription']['expiresAt'] as String)
            : null,
      ),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      deviceToken: json['deviceToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'language': language,
    'country': country,
    'city': city, // ← أضف هنا
    'location': location?.toJson(), // ← أضف هنا
    'subscription': {
      'type': subscription.type,
      'expiresAt': subscription.expiresAt?.toIso8601String(),
    },
    'createdAt': createdAt is Timestamp
        ? (createdAt as Timestamp).toDate().toIso8601String()
        : createdAt.toIso8601String(),
    'deviceToken': deviceToken,
  };

  UserEntity toEntity() => UserEntity(
    uid: uid,
    name: name,
    email: email,
    language: language,
    country: country,
    city: city, // ← أضف هنا
    location: location, // ← أضف هنا
    subscription: subscription,
    createdAt: createdAt,
    deviceToken: deviceToken,
  );

  // دالة مساعدة لإنشاء نسخة معدلة
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? language,
    String? country,
    String? city,
    LocationModel? location,
    SubscriptionEntity? subscription,
    DateTime? createdAt,
    String? deviceToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      language: language ?? this.language,
      country: country ?? this.country,
      city: city ?? this.city,
      location: location ?? this.location,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt ?? this.createdAt,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }
}
