import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/custom_search_field.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/core/widgets/ad_banner_widget.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar_category.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_state.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/screens/all_azkar_view.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/screens/favourit_azkar_view.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/StartTasbeh.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/main_azkr_section_header.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/popular_azkar_grid.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/view/tasbeeh_view.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';

import '../../../../l10n/app_localizations.dart';

class MainAzkarView extends StatefulWidget {
  const MainAzkarView({super.key});

  @override
  State<MainAzkarView> createState() => _MainAzkarViewState();
}

class _MainAzkarViewState extends State<MainAzkarView> {
  // ✅ للبحث
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  // الأذكار المتاحة للنسخة المجانية
  static const List<String> freeAzkar = [
    'أذكار الصباح',
    'أذكار المساء',
    'أذكار النوم',
    'الأذكار بعد السلام من الصلاة المفروضة',
  ];

  @override
  void initState() {
    super.initState();
    // تحميل بيانات الاشتراك
    context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحميل الأذكار - moved here because Localizations depends on InheritedWidget
    final languageCode = Localizations.localeOf(context).languageCode;
    context.read<AzkarBloc>().add(FetchAzkarCategories(languageCode));
  }
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ✅ دالة البحث مع Debouncing
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query.trim();
      });
    });
  }

  // ✅ إزالة التشكيل من النص العربي
  String _removeDiacritics(String text) {
    const diacritics = [
      '\u064B',
      '\u064C',
      '\u064D',
      '\u064E',
      '\u064F',
      '\u0650',
      '\u0651',
      '\u0652',
      '\u0653',
      '\u0654',
      '\u0655',
      '\u0656',
      '\u0640',
    ];

    String result = text;
    for (var diacritic in diacritics) {
      result = result.replaceAll(diacritic, '');
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarBloc, AzkarState>(
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IslamicAppbar(
                      title: AppLocalizations.of(context)!.azkarAndDuas,
                      fontSize: 20.sp,
                      onTap: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 56.h),
                    CustomSearchField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onFavourit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavouritAzkarView(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 48.h),

                    BlocBuilder<AzkarBloc, AzkarState>(
                      builder: (context, state) {
                        if (state is AzkarCategoriesLoaded) {
                          return MainAzkarSectionHeader(
                            title: AppLocalizations.of(context)!.startYourAzkar,
                            actionText: AppLocalizations.of(context)!.seeMore,
                            onActionTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllAzkarView(),
                                ),
                              );
                            },
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),

                    SizedBox(height: 24.h),

                    // استبدال PopularAzkarGrid بالـ Bloc Builder
                    _buildPopularAzkarGrid(),

                    SizedBox(height: 48.h),

                    Text(
                      AppLocalizations.of(context)!.favoriteAzkar,
                      style: AppTextStyles.zekr.copyWith(
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            AppColors.darkRed,
                        fontSize: 16.sp,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    StartTasbehCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TasbehVeiw()),
                        );
                      },
                    ),

                    SizedBox(height: 48.h),

                    // إعلان بانر للمستخدمين المجانيين
                    const AdBannerWidget(
                      useAdaptiveBanner: true,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularAzkarGrid() {
    return BlocBuilder<AzkarBloc, AzkarState>(
      builder: (context, state) {
        if (state is AzkarCategoriesLoaded) {
          // ✅ فلترة الأذكار بناءً على البحث
          final allCategories = state.categories;
          final filteredCategories = _searchQuery.isEmpty
              ? allCategories
              : allCategories.where((category) {
                  // إزالة التشكيل من النص المراد البحث فيه
                  final queryWithoutDiacritics = _removeDiacritics(
                    _searchQuery.toLowerCase(),
                  );
                  final categoryTitleWithoutDiacritics = _removeDiacritics(
                    category.title.toLowerCase(),
                  );

                  return categoryTitleWithoutDiacritics.contains(
                    queryWithoutDiacritics,
                  );
                }).toList();

          // ✅ Wrap with subscription BlocBuilder for access control
          return BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, subscriptionState) {
              // Check if user has premium subscription
              final isPremium =
                  subscriptionState is SubscriptionLoaded &&
                  subscriptionState.subscription.isPremium;

              // Sort categories: free azkar first
              final sortedCategories = List<AzkarCategory>.from(
                filteredCategories,
              );
              sortedCategories.sort((a, b) {
                final aIsFree = freeAzkar.contains(a.title);
                final bIsFree = freeAzkar.contains(b.title);

                if (aIsFree && !bIsFree) return -1;
                if (!aIsFree && bIsFree) return 1;
                return 0;
              });

              // عرض عدد النتائج إذا كان هناك بحث
              if (_searchQuery.isNotEmpty) {
                return Column(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.searchResults}: ${sortedCategories.length} ${AppLocalizations.of(context)!.ofWord} ${allCategories.length}',
                      style: AppTextStyles.surahName.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.goldenColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    PopularAzkarGrid(
                      popularAzkarList: sortedCategories,
                      isPremium: isPremium,
                      freeAzkar: freeAzkar,
                    ),
                  ],
                );
              }

              // Show only first 4 categories on main screen when no search
              final firstFourAzkar = sortedCategories.take(4).toList();
              return PopularAzkarGrid(
                popularAzkarList: firstFourAzkar,
                isPremium: isPremium,
                freeAzkar: freeAzkar,
              );
            },
          );
        } else if (state is AzkarLoading) {
          return Center(child: QuranLottieLoading());
        } else if (state is AzkarError) {
          return Center(
            child: Text(AppLocalizations.of(context)!.errorLoadingAzkar),
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}
