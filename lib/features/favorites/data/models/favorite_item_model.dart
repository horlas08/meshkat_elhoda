import 'package:meshkat_elhoda/features/favorites/domain/entities/favorite_item.dart';

/// ✅ FavoriteItemModel - نموذج البيانات للتحويل من/إلى Firestore
class FavoriteItemModel extends FavoriteItem {
  const FavoriteItemModel({
    required super.id,
    required super.title,
    super.description,
    super.category,
    required super.createdAt,
    super.updatedAt,
  });

  /// ✅ تحويل من Firestore JSON إلى Model
  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    return FavoriteItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// ✅ تحويل من Model إلى JSON للحفظ في Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// ✅ تحويل Entity إلى Model
  factory FavoriteItemModel.fromEntity(FavoriteItem entity) {
    return FavoriteItemModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
