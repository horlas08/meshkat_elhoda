import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/hadith/domain/usecases/get_categories.dart';
import 'package:meshkat_elhoda/features/hadith/domain/usecases/get_hadiths_by_category.dart';
import 'package:meshkat_elhoda/features/hadith/domain/usecases/get_hadith_by_id.dart';
import 'package:meshkat_elhoda/features/hadith/domain/usecases/get_random_hadith.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/bloc/hadith_event.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/bloc/hadith_state.dart';

/// BLoC for managing Hadith feature state with HadeethEnc API
class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final GetCategories getCategories;
  final GetHadithsByCategory getHadithsByCategory;
  final GetHadithById getHadithById;
  final GetRandomHadith getRandomHadith;

  HadithBloc({
    required this.getCategories,
    required this.getHadithsByCategory,
    required this.getHadithById,
    required this.getRandomHadith,
  }) : super(const HadithInitial()) {
    on<GetRootCategoriesEvent>(_onGetRootCategories);
    on<GetSubCategoriesEvent>(_onGetSubCategories);
    on<GetHadithsByCategoryEvent>(_onGetHadithsByCategory);
    on<LoadMoreHadithsEvent>(_onLoadMoreHadiths);
    on<GetHadithByIdEvent>(_onGetHadithById);
    on<GetRandomHadithEvent>(_onGetRandomHadith);
  }

  /// Get root categories
  Future<void> _onGetRootCategories(
    GetRootCategoriesEvent event,
    Emitter<HadithState> emit,
  ) async {
    emit(const HadithLoading());

    final result = await getCategories.getRootCategories(
      languageCode: event.languageCode,
    );

    result.fold(
      (failure) => emit(HadithError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories: categories)),
    );
  }

  /// Get sub-categories
  Future<void> _onGetSubCategories(
    GetSubCategoriesEvent event,
    Emitter<HadithState> emit,
  ) async {
    emit(const HadithLoading());

    final result = await getCategories.getSubCategories(
      parentId: event.parentId,
      languageCode: event.languageCode,
    );

    result.fold(
      (failure) => emit(HadithError(failure.message)),
      (categories) => emit(
        CategoriesLoaded(categories: categories, parentId: event.parentId),
      ),
    );
  }

  /// Get hadiths by category
  Future<void> _onGetHadithsByCategory(
    GetHadithsByCategoryEvent event,
    Emitter<HadithState> emit,
  ) async {
    emit(const HadithLoading());

    final result = await getHadithsByCategory(
      categoryId: event.categoryId,
      page: event.page,
      perPage: event.perPage,
      languageCode: event.languageCode,
    );

    result.fold(
      (failure) => emit(HadithError(failure.message)),
      (response) => emit(
        HadithsLoaded(
          hadiths: response.data,
          meta: response.meta,
          categoryId: event.categoryId,
          categoryName: event.categoryName,
        ),
      ),
    );
  }

  /// Load more hadiths
  Future<void> _onLoadMoreHadiths(
    LoadMoreHadithsEvent event,
    Emitter<HadithState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HadithsLoaded) return;
    if (currentState.isLoadingMore || !currentState.meta.hasNextPage) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getHadithsByCategory(
      categoryId: event.categoryId,
      page: event.nextPage,
      perPage: event.perPage,
      languageCode: event.languageCode,
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (response) {
        emit(
          HadithsLoaded(
            hadiths: [...currentState.hadiths, ...response.data],
            meta: response.meta,
            categoryId: event.categoryId,
            categoryName: event.categoryName ?? currentState.categoryName,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  /// Get hadith by ID
  Future<void> _onGetHadithById(
    GetHadithByIdEvent event,
    Emitter<HadithState> emit,
  ) async {
    emit(const HadithLoading());

    final result = await getHadithById(
      id: event.id,
      languageCode: event.languageCode,
    );

    result.fold(
      (failure) => emit(HadithError(failure.message)),
      (hadith) => emit(HadithLoaded(hadith)),
    );
  }

  /// Get random hadith
  Future<void> _onGetRandomHadith(
    GetRandomHadithEvent event,
    Emitter<HadithState> emit,
  ) async {
    emit(const HadithLoading());

    final result = await getRandomHadith(languageCode: event.languageCode);

    result.fold(
      (failure) => emit(HadithError(failure.message)),
      (hadith) => emit(HadithLoaded(hadith)),
    );
  }
}
