import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/entities/surah_entity.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_bloc.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_event.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_state.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/screens/juz_surahs_screen.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/screens/surah_screen.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/error_widget.dart'
    as custom;
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/hint_search_widget.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/quran_appbar.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/search_text_form_field.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/surah_details_widget.dart';
import 'package:meshkat_elhoda/features/bookmarks/presentation/bloc/bookmark_bloc.dart';
import 'package:meshkat_elhoda/features/bookmarks/presentation/bloc/bookmark_event.dart';
import 'package:meshkat_elhoda/features/bookmarks/presentation/bloc/bookmark_state.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/khatma_progress_bloc.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/khatma_progress_event.dart';

import '../../../../l10n/app_localizations.dart';

class QuranIndexView extends StatefulWidget {
  const QuranIndexView({super.key});

  @override
  State<QuranIndexView> createState() => _QuranIndexViewState();
}

class _QuranIndexViewState extends State<QuranIndexView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  List<SurahEntity> _allSurahs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Trigger initial data load
    context.read<QuranBloc>().add(GetAllSurahsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) =>
          getIt<KhatmaProgressBloc>()..add(LoadKhatmaProgress()),
      child: SafeArea(
        child: Scaffold(
          appBar: QuranAppBar(tabController: _tabController),
          body: Column(
            children: [
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // First Tab - Quran Index
                    BlocBuilder<QuranBloc, QuranState>(
                      builder: (context, state) {
                        // احفظ السور الكاملة عند تحميلها
                        if (state is SurahsLoaded) {
                          _allSurahs = state.surahs;
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                              child: SearchTextFormField(
                                width: double.infinity,
                                controller: _searchController,
                                hintWidget: const HintSearchWidget(),
                                onFieldChanged: (query) {
                                  if (query.isEmpty) {
                                    // إذا كانت البحث فارغة، أرجع لعرض كل السور
                                    context.read<QuranBloc>().add(
                                      GetAllSurahsEvent(),
                                    );
                                  } else {
                                    // ابدأ البحث
                                    context.read<QuranBloc>().add(
                                      SearchSurahsEvent(
                                        query: query,
                                        allSurahs: _allSurahs,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: _buildSearchContent(state, context),
                            ),
                          ],
                        );
                      },
                    ),
                    // Second Tab - Parts (Juz)
                    BlocBuilder<QuranBloc, QuranState>(
                      builder: (context, state) {
                        if (state is Loading) {
                          return QuranLottieLoading(
                            message: localizations?.loading ?? 'Loading...',
                          );
                        }
                        if (state is Error) {
                          return custom.ErrorWidget(
                            message: state.message,
                            onRetry: () {
                              context.read<QuranBloc>().add(
                                GetAllSurahsEvent(),
                              );
                            },
                          );
                        }
                        if (state is SurahsLoaded) {
                          // بناء قائمة الأجزاء
                          final surahsByJuz = <int, List<SurahEntity>>{};
                          for (final surah in state.surahs) {
                            surahsByJuz.putIfAbsent(surah.juzNumber, () => []);
                            surahsByJuz[surah.juzNumber]!.add(surah);
                          }
                          return ListView.builder(
                            itemCount: 30,
                            itemBuilder: (context, index) {
                              final juzNumber = index + 1;
                              return ListTile(
                                title: Text(
                                  '${localizations?.part} $juzNumber',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFFD4A574),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          JuzSurahsScreen(juzNumber: juzNumber),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    // Third Tab - Bookmarks
                    BlocProvider(
                      create: (_) =>
                          getIt<BookmarkBloc>()..add(const GetBookmarksEvent()),
                      child: BlocConsumer<BookmarkBloc, BookmarkState>(
                        listener: (context, state) {
                          if (state is BookmarkDeleted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations?.bookmarkDeletedMessage ??
                                      'Bookmark deleted',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            context.read<BookmarkBloc>().add(
                              const GetBookmarksEvent(),
                            );
                          } else if (state is BookmarkError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is BookmarkLoading) {
                            return QuranLottieLoading(
                              message: localizations?.loading ?? 'Loading...',
                            );
                          }

                          if (state is BookmarkError) {
                            return custom.ErrorWidget(
                              message: state.message,
                              onRetry: () {
                                context.read<BookmarkBloc>().add(
                                  const GetBookmarksEvent(),
                                );
                              },
                            );
                          }

                          if (state is BookmarksLoaded) {
                            if (state.bookmarks.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bookmark_border,
                                      size: 80.sp,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      localizations?.noBookmarks ??
                                          'No bookmarks found',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      localizations?.addBookmarkHint ??
                                          'Add a bookmark from the reading page',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: state.bookmarks.length,
                              itemBuilder: (context, index) {
                                final bookmark = state.bookmarks[index];
                                return _buildBookmarkCard(context, bookmark);
                              },
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchContent(QuranState state, BuildContext context) {
    if (state is Loading) {
      return QuranLottieLoading(message: 'جاري البحث...');
    }
    if (state is Error) {
      log('Error state: ${state.message}');
      return custom.ErrorWidget(
        message: state.message,
        onRetry: () {
          context.read<QuranBloc>().add(GetAllSurahsEvent());
        },
      );
    }
    if (state is SearchResultsLoaded) {
      if (state.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80.sp, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                'لم يتم العثور على نتائج',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }
      return _buildSurahsList(state.searchResults.cast<SurahEntity>());
    }
    if (state is SurahsLoaded) {
      return _buildSurahsList(state.surahs);
    }
    return const SizedBox();
  }

  Widget _buildSurahsList(List<SurahEntity> surahs) {
    // Group surahs by juz
    final surahsByJuz = <int, List<SurahEntity>>{};
    final localizations = AppLocalizations.of(context);

    for (final surah in surahs) {
      surahsByJuz.putIfAbsent(surah.juzNumber, () => []);
      surahsByJuz[surah.juzNumber]!.add(surah);
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: 30, // Fixed number of Juz in Quran
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final juzSurahs = surahsByJuz[juzNumber] ?? [];

        if (juzSurahs.isEmpty) {
          return const SizedBox(); // Skip empty juz
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${localizations?.part ?? 'Part'} $juzNumber',
                style: AppTextStyles.surahName.copyWith(
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      AppColors.darkGrey,
                  fontFamily: AppFonts.tajawal,
                ),
              ),
              SizedBox(height: 8.h),
              ...juzSurahs.asMap().entries.map((entry) {
                final i = entry.key;
                return SurahDetails(
                  arabicName: juzSurahs[i].name,
                  englishName: juzSurahs[i].englishName,
                  numberOfAyats: juzSurahs[i].numberOfAyahs,
                  type: juzSurahs[i].revelationType,
                  arrangement: juzSurahs[i].number,
                  isFirst: i == 0,
                  isLast: i == juzSurahs.length - 1,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahScreen(
                          surahNumber: juzSurahs[i].number,
                          surahName: juzSurahs[i].name,
                        ),
                      ),
                    );
                  },
                );
              }),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookmarkCard(BuildContext context, bookmark) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahScreen(
                surahNumber: bookmark.surahNumber,
                surahName: bookmark.surahName,
                scrollToAyah: bookmark.ayahNumber,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.bookmark,
                      color: const Color(0xFFD4A574),
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookmark.surahName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'الآية ${bookmark.ayahNumber}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[400],
                      size: 24.sp,
                    ),
                    onPressed: () {
                      _showDeleteDialog(context, bookmark);
                    },
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardColor
                      : const Color(0xFFFAF8F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _truncateText(bookmark.ayahText, 100),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1.8,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black87,
                  ),
                ),
              ),
              if (bookmark.note != null && bookmark.note!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).cardColor
                        : Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        color: Colors.amber[700],
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          bookmark.note!,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, bookmark) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          localizations?.deleteBookmarkTitle ?? 'Delete Bookmark',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          localizations?.deleteBookmarkContent ??
              'Are you sure you want to delete this bookmark?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              localizations?.cancel ?? 'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookmarkBloc>().add(
                DeleteBookmarkEvent(bookmark.id),
              );
            },
            child: Text(
              localizations?.delete ?? 'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
