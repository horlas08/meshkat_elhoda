import 'package:equatable/equatable.dart';

/// ✅ FavoriteItem Entity - نموذج البيانات الأساسي للعنصر المفضل
/// يستخدم Equatable للمقارنة بين الكائنات
class FavoriteItem extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? category; // الفئة (قرآن، حديث، إلخ)
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FavoriteItem({
    required this.id,
    required this.title,
    this.description,
    this.category,
    required this.createdAt,
    this.updatedAt,
  });

  /// ✅ نسخ الكائن مع تعديل بعض الحقول
  FavoriteItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    createdAt,
    updatedAt,
  ];
}
