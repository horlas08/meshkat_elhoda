import 'package:meshkat_elhoda/features/favorites/domain/entities/favorite_item.dart';

/// ✅ Abstract Repository Interface
/// يحدد العمليات التي يمكن تنفيذها على المفضلات
abstract class FavoritesRepository {
  /// ✅ الحصول على المفضلات كـ Stream (تحديثات فورية)
  /// عند تغيير البيانات في Firestore، يتم التحديث تلقائياً
  /// لا حاجة لتمرير userId - يتم الحصول عليه من Firebase تلقائياً
  Stream<List<FavoriteItem>> getFavorites();

  /// ✅ إضافة عنصر للمفضلات
  Future<void> addFavorite(FavoriteItem item);

  /// ✅ حذف عنصر من المفضلات
  Future<void> removeFavorite(String itemId);

  /// ✅ التحقق من وجود عنصر في المفضلات
  Future<bool> isFavorite(String itemId);

  /// ✅ حذف جميع المفضلات
  Future<void> clearAllFavorites();
}
