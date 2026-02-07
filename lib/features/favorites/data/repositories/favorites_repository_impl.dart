import 'package:meshkat_elhoda/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:meshkat_elhoda/features/favorites/data/models/favorite_item_model.dart';
import 'package:meshkat_elhoda/features/favorites/domain/entities/favorite_item.dart';
import 'package:meshkat_elhoda/features/favorites/domain/repositories/favorites_repository.dart';

/// ✅ Implementation of FavoritesRepository using Firestore
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<FavoriteItem>> getFavorites() {
    // ✅ تحويل Stream من Model إلى Entity
    return remoteDataSource.getFavorites().map(
      (models) => models.cast<FavoriteItem>(),
    );
  }

  @override
  Future<void> addFavorite(FavoriteItem item) async {
    // ✅ تحويل Entity إلى Model قبل الحفظ
    final model = FavoriteItemModel.fromEntity(item);
    return remoteDataSource.addFavorite(model);
  }

  @override
  Future<void> removeFavorite(String itemId) {
    return remoteDataSource.removeFavorite(itemId);
  }

  @override
  Future<bool> isFavorite(String itemId) {
    return remoteDataSource.isFavorite(itemId);
  }

  @override
  Future<void> clearAllFavorites() {
    return remoteDataSource.clearAllFavorites();
  }
}
