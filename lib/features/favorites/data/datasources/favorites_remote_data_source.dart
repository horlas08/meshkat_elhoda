import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meshkat_elhoda/features/favorites/data/models/favorite_item_model.dart';

/// ✅ Abstract Remote Data Source Interface
abstract class FavoritesRemoteDataSource {
  /// ✅ الحصول على المفضلات كـ Stream (بدون تمرير userId)
  Stream<List<FavoriteItemModel>> getFavorites();

  /// ✅ إضافة عنصر للمفضلات
  Future<void> addFavorite(FavoriteItemModel item);

  /// ✅ حذف عنصر من المفضلات
  Future<void> removeFavorite(String itemId);

  /// ✅ التحقق من وجود عنصر
  Future<bool> isFavorite(String itemId);

  /// ✅ حذف جميع المفضلات
  Future<void> clearAllFavorites();
}

/// ✅ Firestore Implementation
class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoritesRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  /// ✅ الحصول على معرف المستخدم الحالي من Firebase
  String _getCurrentUserId() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('❌ المستخدم غير مسجل دخول');
    return uid;
  }

  /// ✅ مسار المجموعة: users/{userId}/favorites
  String _getFavoritesPath() => 'users/${_getCurrentUserId()}/favorites';

  @override
  Stream<List<FavoriteItemModel>> getFavorites() {
    // ✅ الاستماع لتغييرات Firestore في الوقت الفعلي
    return _firestore.collection(_getFavoritesPath()).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => FavoriteItemModel.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> addFavorite(FavoriteItemModel item) async {
    try {
      await _firestore
          .collection(_getFavoritesPath())
          .doc(item.id)
          .set(item.toJson());
    } catch (e) {
      throw Exception('❌ خطأ في إضافة المفضل: $e');
    }
  }

  @override
  Future<void> removeFavorite(String itemId) async {
    try {
      await _firestore.collection(_getFavoritesPath()).doc(itemId).delete();
    } catch (e) {
      throw Exception('❌ خطأ في حذف المفضل: $e');
    }
  }

  @override
  Future<bool> isFavorite(String itemId) async {
    try {
      final doc = await _firestore
          .collection(_getFavoritesPath())
          .doc(itemId)
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('❌ خطأ في التحقق من المفضل: $e');
    }
  }

  @override
  Future<void> clearAllFavorites() async {
    try {
      final batch = _firestore.batch();
      final docs = await _firestore.collection(_getFavoritesPath()).get();

      for (var doc in docs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('❌ خطأ في حذف جميع المفضلات: $e');
    }
  }
}
