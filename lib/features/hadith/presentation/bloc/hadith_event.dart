import 'package:equatable/equatable.dart';

/// Base class for all Hadith events
abstract class HadithEvent extends Equatable {
  const HadithEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch root categories
class GetRootCategoriesEvent extends HadithEvent {
  final String? languageCode;

  const GetRootCategoriesEvent({this.languageCode});

  @override
  List<Object?> get props => [languageCode];
}

/// Event to fetch sub-categories
class GetSubCategoriesEvent extends HadithEvent {
  final String parentId;
  final String? languageCode;

  const GetSubCategoriesEvent({required this.parentId, this.languageCode});

  @override
  List<Object?> get props => [parentId, languageCode];
}

/// Event to fetch hadiths by category
class GetHadithsByCategoryEvent extends HadithEvent {
  final String categoryId;
  final String? categoryName;
  final int page;
  final int perPage;
  final String? languageCode;

  const GetHadithsByCategoryEvent({
    required this.categoryId,
    this.categoryName,
    this.page = 1,
    this.perPage = 20,
    this.languageCode,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    page,
    perPage,
    languageCode,
  ];
}

/// Event to load more hadiths in current category
class LoadMoreHadithsEvent extends HadithEvent {
  final String categoryId;
  final String? categoryName;
  final int nextPage;
  final int perPage;
  final String? languageCode;

  const LoadMoreHadithsEvent({
    required this.categoryId,
    this.categoryName,
    required this.nextPage,
    this.perPage = 20,
    this.languageCode,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    nextPage,
    perPage,
    languageCode,
  ];
}

/// Event to fetch a specific hadith by ID
class GetHadithByIdEvent extends HadithEvent {
  final String id;
  final String? languageCode;

  const GetHadithByIdEvent({required this.id, this.languageCode});

  @override
  List<Object?> get props => [id, languageCode];
}

/// Event to fetch a random hadith
class GetRandomHadithEvent extends HadithEvent {
  final String? languageCode;

  const GetRandomHadithEvent({this.languageCode});

  @override
  List<Object?> get props => [languageCode];
}
