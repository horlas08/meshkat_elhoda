import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/widgets/custom_search_field.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/core/widgets/ad_banner_widget.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/bloc/hadith_bloc.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/bloc/hadith_event.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/bloc/hadith_state.dart';
import 'package:meshkat_elhoda/features/hadith/data/models/hadith_category_model.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_event.dart';

import 'hadith_details_page.dart';

class AhadithView extends StatefulWidget {
  const AhadithView({super.key});

  @override
  State<AhadithView> createState() => _AhadithViewState();
}

class _AhadithViewState extends State<AhadithView> {
  late HadithBloc hadithBloc;
  late FavoritesBloc favoritesBloc;

  // للبحث
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  // للـ Infinite Scroll
  final ScrollController _scrollController = ScrollController();

  // Navigation stack for categories
  final List<_CategoryLevel> _categoryStack = [];

  @override
  void initState() {
    super.initState();
    hadithBloc = getIt<HadithBloc>();
    favoritesBloc = getIt<FavoritesBloc>();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRootCategories();
    });
    favoritesBloc.add(const LoadFavorites());
  }

  void _loadRootCategories() {
    final languageCode = Localizations.localeOf(context).languageCode;
    hadithBloc.add(GetRootCategoriesEvent(languageCode: languageCode));
  }

  void _loadSubCategories(HadithCategory category) {
    final languageCode = Localizations.localeOf(context).languageCode;
    _categoryStack.add(_CategoryLevel(id: category.id, title: category.title));
    setState(() {});
    hadithBloc.add(
      GetSubCategoriesEvent(parentId: category.id, languageCode: languageCode),
    );
  }

  void _loadHadithsByCategory(HadithCategory category) {
    final languageCode = Localizations.localeOf(context).languageCode;
    _categoryStack.add(
      _CategoryLevel(
        id: category.id,
        title: category.title,
        isHadithsList: true,
      ),
    );
    setState(() {});
    hadithBloc.add(
      GetHadithsByCategoryEvent(
        categoryId: category.id,
        categoryName: category.title,
        languageCode: languageCode,
      ),
    );
  }

  void _loadMoreHadiths() {
    final currentState = hadithBloc.state;
    if (currentState is HadithsLoaded &&
        currentState.meta.hasNextPage &&
        !currentState.isLoadingMore) {
      final languageCode = Localizations.localeOf(context).languageCode;
      hadithBloc.add(
        LoadMoreHadithsEvent(
          categoryId: currentState.categoryId,
          categoryName: currentState.categoryName,
          nextPage: currentState.meta.currentPage + 1,
          languageCode: languageCode,
        ),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreHadiths();
    }
  }

  void _goBack() {
    if (_categoryStack.isNotEmpty) {
      _categoryStack.removeLast();
      setState(() {});

      if (_categoryStack.isEmpty) {
        _loadRootCategories();
      } else {
        final parent = _categoryStack.last;
        final languageCode = Localizations.localeOf(context).languageCode;

        if (parent.isHadithsList) {
          hadithBloc.add(
            GetHadithsByCategoryEvent(
              categoryId: parent.id,
              categoryName: parent.title,
              languageCode: languageCode,
            ),
          );
        } else {
          _categoryStack.removeLast();
          setState(() {});
          hadithBloc.add(
            GetSubCategoriesEvent(
              parentId: parent.id,
              languageCode: languageCode,
            ),
          );
        }
      }
    }
  }

  void _openHadithDetails(HadithListItem item) {
    final languageCode = Localizations.localeOf(context).languageCode;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HadithDetailsPage(hadithId: item.id, languageCode: languageCode),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _getCurrentTitle() {
    if (_categoryStack.isEmpty) {
      return AppLocalizations.of(context)?.hadiths ?? 'الأحاديث';
    }
    return _categoryStack.last.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: IslamicAppbar(
                title: _getCurrentTitle(),
                fontSize: 20.sp,
                onTap: () {
                  if (_categoryStack.isNotEmpty) {
                    _goBack();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),

            // Search Field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomSearchField(
                controller: _searchController,
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  });
                },
              ),
            ),

            SizedBox(height: 8.h),

            Center(
              child: Text(
                AppLocalizations.of(context)?.copyrightHadithNotice ??
                    'الأحاديث',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ),

            SizedBox(height: 8.h),

            // Main Content
            Expanded(
              child: BlocBuilder<HadithBloc, HadithState>(
                bloc: hadithBloc,
                builder: (context, state) {
                  if (state is HadithLoading) {
                    return const QuranLottieLoading();
                  }

                  if (state is HadithError) {
                    return _buildErrorWidget(state.message);
                  }

                  if (state is CategoriesLoaded) {
                    return _buildCategoriesList(state.categories);
                  }

                  if (state is HadithsLoaded) {
                    return _buildHadithsList(state);
                  }

                  return const QuranLottieLoading();
                },
              ),
            ),

            // Ad Banner
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              if (_categoryStack.isEmpty) {
                _loadRootCategories();
              } else {
                _goBack();
              }
            },
            child: Text(
              AppLocalizations.of(context)?.retry ?? 'إعادة المحاولة',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(List<HadithCategory> categories) {
    // Filter by search
    final filteredCategories = _searchQuery.isEmpty
        ? categories
        : categories
              .where((cat) => cat.title.toLowerCase().contains(_searchQuery))
              .toList();

    if (filteredCategories.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.noData ?? 'لا توجد بيانات',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        return _CategoryCard(
          category: category,
          onTap: () {
            if (category.hadithsCount > 0) {
              // Load hadiths if this category has direct hadiths
              _loadHadithsByCategory(category);
            } else {
              // Load sub-categories
              _loadSubCategories(category);
            }
          },
        );
      },
    );
  }

  Widget _buildHadithsList(HadithsLoaded state) {
    // Filter by search
    final filteredHadiths = _searchQuery.isEmpty
        ? state.hadiths
        : state.hadiths
              .where((h) => h.title.toLowerCase().contains(_searchQuery))
              .toList();

    if (filteredHadiths.isEmpty && !state.isLoadingMore) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.noData ?? 'لا توجد أحاديث',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: filteredHadiths.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredHadiths.length) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final hadith = filteredHadiths[index];
        return _HadithCard(
          hadith: hadith,
          onTap: () => _openHadithDetails(hadith),
        );
      },
    );
  }
}

class _CategoryLevel {
  final String id;
  final String title;
  final bool isHadithsList;

  _CategoryLevel({
    required this.id,
    required this.title,
    this.isHadithsList = false,
  });
}

class _CategoryCard extends StatelessWidget {
  final HadithCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${category.hadithsCount} ${AppLocalizations.of(context)?.hadiths ?? 'حديث'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.goldenColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.goldenColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final HadithListItem hadith;
  final VoidCallback onTap;

  const _HadithCard({required this.hadith, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hadith.title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Available translations
                  if (hadith.translations.isNotEmpty)
                    Expanded(
                      child: Wrap(
                        spacing: 4.w,
                        children: hadith.translations.take(5).map((lang) {
                          return Chip(
                            label: Text(
                              lang.toUpperCase(),
                              style: TextStyle(fontSize: 10.sp),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                          );
                        }).toList(),
                      ),
                    ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
                    color: AppColors.goldenColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
