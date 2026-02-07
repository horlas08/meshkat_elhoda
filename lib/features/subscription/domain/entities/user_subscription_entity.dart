import 'package:equatable/equatable.dart';

class UserSubscriptionEntity extends Equatable {
  final String type; // "free", "premium", "monthly", or "yearly"
  final DateTime? expireAt;

  const UserSubscriptionEntity({required this.type, this.expireAt});

  bool get isPremium {
    // التحقق من أن النوع ليس مجاني
    if (type == 'free') return false;

    // إذا لم يكن هناك تاريخ انتهاء، يعتبر نشط (للاشتراكات الدائمة)
    if (expireAt == null) return true;

    // التحقق من أن الاشتراك لم ينتهي بعد
    return expireAt!.isAfter(DateTime.now());
  }

  @override
  List<Object?> get props => [type, expireAt];
}
