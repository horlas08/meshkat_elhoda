import '../../domain/entities/user_subscription_entity.dart';

class UserSubscriptionModel extends UserSubscriptionEntity {
  const UserSubscriptionModel({required super.type, super.expireAt});

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      type: json['type'] as String? ?? 'free',
      expireAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : (json['expireAt'] != null
                ? DateTime.parse(json['expireAt'] as String)
                : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'expireAt': expireAt?.toIso8601String()};
  }

  factory UserSubscriptionModel.fromEntity(UserSubscriptionEntity entity) {
    return UserSubscriptionModel(type: entity.type, expireAt: entity.expireAt);
  }
}
