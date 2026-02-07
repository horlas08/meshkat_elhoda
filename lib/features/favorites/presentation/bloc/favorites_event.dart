import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/favorites/domain/entities/favorite_item.dart';

/// ✅ Base Event for FavoritesBloc
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// ✅ Event: تحميل المفضلات للمستخدم الحالي
class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

/// ✅ Event: إضافة عنصر للمفضلات
class AddFavorite extends FavoritesEvent {
  final FavoriteItem item;

  const AddFavorite({required this.item});

  @override
  List<Object?> get props => [item];
}

/// ✅ Event: حذف عنصر من المفضلات
class RemoveFavorite extends FavoritesEvent {
  final String itemId;

  const RemoveFavorite({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

/// ✅ Event: التحقق من وجود عنصر في المفضلات
class CheckIfFavorite extends FavoritesEvent {
  final String itemId;

  const CheckIfFavorite({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

/// ✅ Event: حذف جميع المفضلات
class ClearAllFavorites extends FavoritesEvent {
  const ClearAllFavorites();
}
