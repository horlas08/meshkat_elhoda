import 'package:equatable/equatable.dart';

/// Model for Hadith Category from HadeethEnc API
class HadithCategory extends Equatable {
  final String id;
  final String title;
  final int hadithsCount;
  final String? parentId;

  const HadithCategory({
    required this.id,
    required this.title,
    required this.hadithsCount,
    this.parentId,
  });

  factory HadithCategory.fromJson(Map<String, dynamic> json) {
    return HadithCategory(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      hadithsCount:
          int.tryParse(json['hadeeths_count']?.toString() ?? '0') ?? 0,
      parentId: json['parent_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hadeeths_count': hadithsCount.toString(),
      'parent_id': parentId,
    };
  }

  bool get isRootCategory => parentId == null;

  @override
  List<Object?> get props => [id, title, hadithsCount, parentId];
}

/// Model for Hadith list item (basic info)
class HadithListItem extends Equatable {
  final String id;
  final String title;
  final List<String> translations;

  const HadithListItem({
    required this.id,
    required this.title,
    required this.translations,
  });

  factory HadithListItem.fromJson(Map<String, dynamic> json) {
    return HadithListItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      translations:
          (json['translations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, title, translations];
}

/// Model for pagination metadata
class HadithPaginationMeta extends Equatable {
  final int currentPage;
  final int lastPage;
  final int totalItems;
  final int perPage;

  const HadithPaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.totalItems,
    required this.perPage,
  });

  factory HadithPaginationMeta.fromJson(Map<String, dynamic> json) {
    return HadithPaginationMeta(
      currentPage: int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      totalItems: int.tryParse(json['total_items']?.toString() ?? '0') ?? 0,
      perPage: int.tryParse(json['per_page']?.toString() ?? '20') ?? 20,
    );
  }

  bool get hasNextPage => currentPage < lastPage;

  @override
  List<Object?> get props => [currentPage, lastPage, totalItems, perPage];
}

/// Response model for hadith list endpoint
class HadithListResponse {
  final List<HadithListItem> data;
  final HadithPaginationMeta meta;

  const HadithListResponse({required this.data, required this.meta});

  factory HadithListResponse.fromJson(Map<String, dynamic> json) {
    return HadithListResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => HadithListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: HadithPaginationMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
