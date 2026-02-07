import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/favorites/domain/entities/favorite_item.dart';

/// ✅ Base State for FavoritesBloc
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// ✅ State: الحالة الأولية
class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

/// ✅ State: جاري التحميل
class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

/// ✅ State: تم التحميل بنجاح مع قائمة المفضلات
class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItem> favorites;
  final bool isItemFavorite; // ✅ للتحقق من وجود عنصر محدد

  const FavoritesLoaded({required this.favorites, this.isItemFavorite = false});

  /// ✅ تحديث الحالة مع تعديل بعض الحقول
  FavoritesLoaded copyWith({
    List<FavoriteItem>? favorites,
    bool? isItemFavorite,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      isItemFavorite: isItemFavorite ?? this.isItemFavorite,
    );
  }

  @override
  List<Object?> get props => [favorites, isItemFavorite];
}

/// ✅ State: حدث خطأ
class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// ✅ State: تمت العملية بنجاح (إضافة/حذف)
/// ✅ State: تمت العملية بنجاح (إضافة/حذف)
class FavoritesSuccess extends FavoritesLoaded {
  final String message;
  final FavoriteItem? item;

  const FavoritesSuccess({
    required this.message,
    required List<FavoriteItem> favorites,
    this.item,
    bool isItemFavorite = false,
  }) : super(favorites: favorites, isItemFavorite: isItemFavorite);

  @override
  List<Object?> get props => [message, item, favorites, isItemFavorite];
}
