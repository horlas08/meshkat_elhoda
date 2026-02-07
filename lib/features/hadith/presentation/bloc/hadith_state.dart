import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/hadith/domain/entities/hadith.dart';
import 'package:meshkat_elhoda/features/hadith/data/models/hadith_category_model.dart';

/// Base class for all Hadith states
abstract class HadithState extends Equatable {
  const HadithState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class HadithInitial extends HadithState {
  const HadithInitial();
}

/// State when loading
class HadithLoading extends HadithState {
  const HadithLoading();
}

/// State when categories are loaded successfully
class CategoriesLoaded extends HadithState {
  final List<HadithCategory> categories;
  final String? parentId; // null for root categories

  const CategoriesLoaded({required this.categories, this.parentId});

  @override
  List<Object?> get props => [categories, parentId];
}

/// State when a single hadith is loaded successfully
class HadithLoaded extends HadithState {
  final Hadith hadith;

  const HadithLoaded(this.hadith);

  @override
  List<Object?> get props => [hadith];
}

/// State when multiple hadiths are loaded successfully
class HadithsLoaded extends HadithState {
  final List<HadithListItem> hadiths;
  final HadithPaginationMeta meta;
  final String categoryId;
  final String? categoryName;
  final bool isLoadingMore;

  const HadithsLoaded({
    required this.hadiths,
    required this.meta,
    required this.categoryId,
    this.categoryName,
    this.isLoadingMore = false,
  });

  HadithsLoaded copyWith({
    List<HadithListItem>? hadiths,
    HadithPaginationMeta? meta,
    String? categoryId,
    String? categoryName,
    bool? isLoadingMore,
  }) {
    return HadithsLoaded(
      hadiths: hadiths ?? this.hadiths,
      meta: meta ?? this.meta,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    hadiths,
    meta,
    categoryId,
    categoryName,
    isLoadingMore,
  ];
}

/// State when an error occurs
class HadithError extends HadithState {
  final String message;

  const HadithError(this.message);

  @override
  List<Object?> get props => [message];
}
