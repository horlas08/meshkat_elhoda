import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/favorites/domain/entities/favorite_item.dart';
import 'package:meshkat_elhoda/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_state.dart';

/// ✅ FavoritesBloc - إدارة حالة المفضلات
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository repository;

  FavoritesBloc({required this.repository}) : super(const FavoritesInitial()) {
    // ✅ تسجيل معالجات الأحداث
    on<LoadFavorites>(_onLoadFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
    on<CheckIfFavorite>(_onCheckIfFavorite);
    on<ClearAllFavorites>(_onClearAllFavorites);
  }

  /// ✅ معالج تحميل المفضلات
  /// يستمع للتحديثات في الوقت الفعلي من Firestore
  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    try {
      // ✅ استخدام emit.forEach للتعامل الصحيح مع Stream
      await emit.forEach<List<FavoriteItem>>(
        repository.getFavorites(),
        onData: (favorites) {
          dev.log('✅ تم تحديث المفضلات: ${favorites.length} عنصر');
          return FavoritesLoaded(favorites: favorites);
        },
        onError: (error, stackTrace) {
          dev.log('❌ خطأ في تحديث المفضلات: $error');
          return FavoritesError(message: error.toString());
        },
      );
    } catch (e) {
      dev.log('❌ خطأ في تحميل المفضلات: $e');
      emit(FavoritesError(message: e.toString()));
    }
  }

  /// ✅ معالج إضافة عنصر للمفضلات
  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      dev.log('➕ إضافة عنصر للمفضلات: ${event.item.title}');
      await repository.addFavorite(event.item);

      List<FavoriteItem> currentFavorites = [];
      if (state is FavoritesLoaded) {
        currentFavorites = (state as FavoritesLoaded).favorites;
      }
      // Note: ideally we should add the item to the local list immediately for optimistic UI,
      // but since we rely on the stream to update the list eventually,
      // we just pass the current list (or maybe we should append it locally to avoid flicker?)
      // For now, let's pass the current list. If the stream updates, it will emit a new Loaded state.
      // Actually, if we don't add it locally, the UI might not show it as favorite immediately if it relies on the list.
      // But the UI checks "isFavorite" based on the list.
      // So we SHOULD add it locally to the list we pass to Success.

      final updatedFavorites = List<FavoriteItem>.from(currentFavorites);
      if (!updatedFavorites.any((i) => i.id == event.item.id)) {
        updatedFavorites.add(event.item);
      }

      emit(
        FavoritesSuccess(
          message: '✅ تمت إضافة "${event.item.title}" للمفضلات',
          item: event.item,
          favorites: updatedFavorites,
          isItemFavorite: true,
        ),
      );
    } catch (e) {
      dev.log('❌ خطأ في إضافة المفضل: $e');
      emit(FavoritesError(message: 'فشل في إضافة المفضل'));
    }
  }

  /// ✅ معالج حذف عنصر من المفضلات
  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      dev.log('❌ حذف عنصر من المفضلات: ${event.itemId}');
      await repository.removeFavorite(event.itemId);

      List<FavoriteItem> currentFavorites = [];
      if (state is FavoritesLoaded) {
        currentFavorites = (state as FavoritesLoaded).favorites;
      }

      final updatedFavorites = List<FavoriteItem>.from(currentFavorites);
      updatedFavorites.removeWhere((item) => item.id == event.itemId);

      emit(
        FavoritesSuccess(
          message: '✅ تمت إزالة العنصر من المفضلات',
          favorites: updatedFavorites,
          isItemFavorite: false,
        ),
      );
    } catch (e) {
      dev.log('❌ خطأ في حذف المفضل: $e');
      emit(FavoritesError(message: 'فشل في حذف المفضل'));
    }
  }

  /// ✅ معالج التحقق من وجود عنصر في المفضلات
  Future<void> _onCheckIfFavorite(
    CheckIfFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorite = await repository.isFavorite(event.itemId);
      dev.log('🔍 هل العنصر في المفضلات؟ $isFavorite');

      if (state is FavoritesLoaded) {
        final currentState = state as FavoritesLoaded;
        emit(currentState.copyWith(isItemFavorite: isFavorite));
      } else {
        // If not loaded, we still want to emit the status
        emit(FavoritesLoaded(favorites: const [], isItemFavorite: isFavorite));
      }
    } catch (e) {
      dev.log('❌ خطأ في التحقق من المفضل: $e');
      emit(FavoritesError(message: 'فشل في التحقق من المفضل'));
    }
  }

  /// ✅ معالج حذف جميع المفضلات
  Future<void> _onClearAllFavorites(
    ClearAllFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      dev.log('🗑️ حذف جميع المفضلات');
      await repository.clearAllFavorites();
      emit(
        const FavoritesSuccess(
          message: '✅ تم حذف جميع المفضلات',
          favorites: [],
        ),
      );
    } catch (e) {
      dev.log('❌ خطأ في حذف جميع المفضلات: $e');
      emit(FavoritesError(message: 'فشل في حذف المفضلات'));
    }
  }
}
