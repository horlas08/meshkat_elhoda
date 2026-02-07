import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar_category.dart';

class AzkarCategoryModel extends AzkarCategory {
  const AzkarCategoryModel({
    required super.id,
    required super.title,
    super.description,
  });

  factory AzkarCategoryModel.fromJson(Map<String, dynamic> json) {
    return AzkarCategoryModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  factory AzkarCategoryModel.fromEntity(AzkarCategory category) {
    return AzkarCategoryModel(
      id: category.id,
      title: category.title,
      description: category.description,
    );
  }
}
