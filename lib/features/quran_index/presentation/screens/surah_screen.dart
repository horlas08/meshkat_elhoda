import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/entities/ayah_entity.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_bloc.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_event.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_state.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/audio_dialoge.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/error_widget.dart'
    as custom;
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/tafsier_dialog.dart';
import 'package:meshkat_elhoda/features/bookmarks/presentation/bloc/bookmark_bloc.dart';
import 'package:meshkat_elhoda/features/bookmarks/presentation/bloc/bookmark_event.dart';
import 'package:meshkat_elhoda/features/bookmarks/presentation/bloc/bookmark_state.dart';
import 'package:meshkat_elhoda/features/bookmarks/presentation/widgets/add_bookmark_dialog.dart';
import 'package:meshkat_elhoda/features/bookmarks/presentation/screens/bookmarks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/surah_download_cubit.dart';

import 'package:meshkat_elhoda/core/utils/quran_pages.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/khatma_progress_bloc.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/khatma_progress_event.dart';

import '../../../../l10n/app_localizations.dart';

enum ReadingMode { vertical, horizontal }

class SurahScreen extends StatefulWidget {
  final int? surahNumber;
  final String? surahName;
  final int? scrollToAyah;
  final int? initialPage;
  final bool forceHorizontalMode;
  final bool isKhatmah;

  const SurahScreen({
    super.key,
    this.surahNumber,
    this.surahName,
    this.scrollToAyah,
    this.initialPage,
    this.forceHorizontalMode = false,
    this.isKhatmah = false,
  }) : assert(
         (surahNumber != null && surahName != null) || initialPage != null,
         'Either surahNumber/surahName OR initialPage must be provided',
       );

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  ReadingMode _readingMode = ReadingMode.vertical;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _ayahKey = GlobalKey();
  bool _hasScrolledToAyah = false;
  bool _hasJumpedToPage = false;

  // For saving reading position
  int _currentPage = 0;
  double _scrollPosition = 0.0;

  // Cache ayahs to prevent losing them during tafsir operations
  List<AyahEntity>? _cachedAyahs;

  late final int _surahNumber;
  late final String _surahName;

  @override
  void initState() {
    super.initState();

    if (widget.initialPage != null) {
      final data = QuranPages.getSurahDataForPage(widget.initialPage!);
      _surahNumber = data.surahNumber;
      _surahName = data.surahName;
      _readingMode = ReadingMode.horizontal; // للختمة
    } else {
      _surahNumber = widget.surahNumber!;
      _surahName = widget.surahName!;
    }

    // إذا كان forceHorizontalMode، ابدأ بالوضع الأفقي
    if (widget.forceHorizontalMode) {
      _readingMode = ReadingMode.horizontal;
    }

    // TODO: Load saved reading mode and position from preferences

    _scrollController.addListener(() {
      _scrollPosition = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<List<AyahEntity>> _splitAyahsByPage(List<AyahEntity> ayahs) {
    // تجميع الآيات حسب رقم الصفحة
    final Map<int, List<AyahEntity>> pagesMap = {};

    for (final ayah in ayahs) {
      final pageNumber = ayah.page;
      if (!pagesMap.containsKey(pageNumber)) {
        pagesMap[pageNumber] = [];
      }
      pagesMap[pageNumber]!.add(ayah);
    }

    // تحويل الـ Map إلى List مرتبة حسب رقم الصفحة
    final sortedPages = pagesMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedPages.map((entry) => entry.value).toList();
  }

  void _scrollToTargetAyah() {
    // فقط في الوضع العمودي
    if (widget.scrollToAyah != null &&
        !_hasScrolledToAyah &&
        _readingMode == ReadingMode.vertical) {
      log('Attempting to scroll to ayah: ${widget.scrollToAyah}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // انتظر قليلاً للتأكد من اكتمال البناء
        Future.delayed(const Duration(milliseconds: 300), () {
          final context = _ayahKey.currentContext;
          log('Ayah context found: ${context != null}');
          if (context != null && mounted) {
            log('Scrolling to ayah ${widget.scrollToAyah}');
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              alignment: 0.15, // الآية ستظهر في الجزء العلوي من الشاشة
            );
            if (mounted) {
              setState(() {
                _hasScrolledToAyah = true;
              });
            }
          } else {
            log('Failed to scroll: context is null or widget unmounted');
          }
        });
      });
    }
  }

  void _saveReadingPosition() {
    context.read<QuranBloc>().add(GetAllSurahsEvent());
    // TODO: Save to SharedPreferences
    if (_readingMode == ReadingMode.horizontal) {
      // Save current page number
      print('Saving page: $_currentPage');
    } else {
      // Save scroll position
      print('Saving scroll position: $_scrollPosition');
    }
  }

  void _toggleReadingMode() {
    setState(() {
      _readingMode = _readingMode == ReadingMode.vertical
          ? ReadingMode.horizontal
          : ReadingMode.vertical;
    });
    _saveReadingPosition();
  }

  void _showReadingModeDialog() {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations?.readingModeTitle ?? 'Reading Mode',
                style: AppTextStyles.surahName.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.blacColor
                      : AppColors.whiteColor,
                ),
              ),
              SizedBox(height: 20.h),

              _buildReadingModeOption(
                icon: Icons.swap_vert,
                title:
                    localizations?.readingModeVerticalTitle ??
                    'Vertical Scroll',
                subtitle:
                    localizations?.readingModeVerticalSubtitle ??
                    'Scroll up and down',
                isSelected: _readingMode == ReadingMode.vertical,
                onTap: () {
                  Navigator.pop(context);
                  if (_readingMode != ReadingMode.vertical) {
                    _toggleReadingMode();
                  }
                },
              ),
              SizedBox(height: 12.h),

              _buildReadingModeOption(
                icon: Icons.swap_horiz,
                title: localizations?.readingModeHorizontalTitle ?? 'Page Flip',
                subtitle:
                    localizations?.readingModeHorizontalSubtitle ??
                    'Flip right and left',
                isSelected: _readingMode == ReadingMode.horizontal,
                onTap: () {
                  Navigator.pop(context);
                  if (_readingMode != ReadingMode.horizontal) {
                    _toggleReadingMode();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingModeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4A574).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4A574) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFD4A574) : Colors.grey[600],
              size: 32.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.black87)
                          : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFFD4A574),
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _showAyahOptionsDialog(BuildContext parentContext, AyahEntity ayah) {
    final quranBloc = parentContext.read<QuranBloc>();
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: parentContext,
      barrierColor: Colors.black54,
      builder: (context) => BlocProvider.value(
        value: parentContext.read<SurahDownloadCubit>(),
        child: Dialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${localizations?.ayah ?? 'Ayah'} ${ayah.numberInSurah}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.surahName.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.blacColor
                        : AppColors.whiteColor,
                  ),
                ),
                SizedBox(height: 20.h),

                _buildDialogOption(
                  icon: Icons.bookmark_add_outlined,
                  iconColor: const Color(0xFFD4A574),
                  label: localizations?.ayahOptionAddBookmark ?? 'Add Bookmark',
                  onTap: () {
                    Navigator.pop(context);
                    _showAddBookmarkDialog(parentContext, ayah);
                  },
                ),
                SizedBox(height: 12.h),

                _buildDialogOption(
                  icon: Icons.play_circle_outline,
                  iconColor: const Color(0xFFD4A574),
                  label: localizations?.ayahOptionPlay ?? 'Play',
                  onTap: () {
                    Navigator.pop(context);
                    _playSingleAyah(ayah);
                  },
                ),
                SizedBox(height: 12.h),

                _buildDialogOption(
                  icon: Icons.book_outlined,
                  iconColor: const Color(0xFFD4A574),
                  label: localizations?.ayahOptionTafsir ?? 'Tafsir',
                  onTap: () {
                    Navigator.pop(context); // أقفل dialog الخيارات

                    // أظهر dialog التفسير مع الـ Bloc
                    showDialog(
                      context: parentContext,
                      barrierDismissible:
                          false, // عشان ميقفلش لحد ما التفسير يحمل
                      builder: (dialogContext) => BlocProvider.value(
                        value: quranBloc,
                        child: TafsirDialog(
                          surahNumber: _surahNumber,
                          ayahNumber: ayah.numberInSurah,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                _buildDialogOption(
                  icon: Icons.copy_outlined,
                  iconColor: const Color(0xFFD4A574),
                  label: localizations?.copy ?? 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: ayah.text)).then((_) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text('Copied to clipboard'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddBookmarkDialog(BuildContext context, AyahEntity ayah) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => getIt<BookmarkBloc>(),
        child: BlocConsumer<BookmarkBloc, BookmarkState>(
          listener: (context, state) {
            if (state is BookmarkAdded) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    localizations?.bookmarkAddedMessage ??
                        'Bookmark added successfully',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
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
            return AddBookmarkDialog(
              surahNumber: _surahNumber,
              surahName: _surahName,
              ayahNumber: ayah.numberInSurah,
              ayahText: ayah.text,
              onConfirm: (note) {
                context.read<BookmarkBloc>().add(
                  AddBookmarkEvent(
                    surahNumber: _surahNumber,
                    surahName: _surahName,
                    ayahNumber: ayah.numberInSurah,
                    ayahText: ayah.text,
                    note: note,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDialogOption({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios, size: 16.sp, color: Colors.grey[600]),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(icon, color: iconColor, size: 24.sp),
          ],
        ),
      ),
    );
  }

  // في أي مكان في الكود، استدعي الخدمة كالتالي:

  // لتشغيل آية واحدة
  void _playSingleAyah(AyahEntity ayah) {
    showDialog(
      context: context,
      builder: (context) => AudioPlayerDialog(
        audioUrl: ayah.audio,
        ayahText: ayah.text,
        surahName: _surahName,
        ayahNumber: ayah.numberInSurah,
      ),
    );
  }

  Widget _buildAyahNumber(int number) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // الصورة فقط
        Container(
          width: 28.w,
          height: 28.w,
          color: Colors.transparent,
          child: Image.asset(
            'assets/images/ayah_border2.png',
            fit: BoxFit.fill,
          ),
        ),
        // الرقم في الموضع الدقيق
        Positioned(
          top: 5.h,
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4A574),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Top decoration border (optional)
        Container(
          height: 110.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/sura_border.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Text(
              '$_surahName',
              style: TextStyle(
                fontFamily: AppFonts.quran,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black87,
              ),
            ),
          ),
        ),

        // Surah name container
        /* Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          padding: EdgeInsets.symmetric(vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4A574), width: 1.5),
          ),
          child: Center(
            child: Text(
              '${widget.surahName}',
              style: TextStyle(
                fontFamily: AppFonts.quran,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),*/
      ],
    );
  }

  Widget _buildAyahsContent(
    BuildContext context,
    List<AyahEntity> ayahs, {
    double? minHeight,
  }) {
    final isFatiha = _surahNumber == 1;

    // ✅ التحقق مما إذا كانت هناك ترجمات
    final hasTranslations = ayahs.any(
      (a) => a.translation != null && a.translation!.isNotEmpty,
    );

    // ✅ إذا كانت هناك ترجمات، استخدم طريقة العرض الجديدة
    if (hasTranslations) {
      return _buildAyahsWithTranslationsLayout(
        context,
        ayahs,
        minHeight: minHeight,
      );
    }

    final bismillahRegex = RegExp(
      r'بِسْمِ.*الله.*الرَّحْمَٰنِ.*الرَّحِيمِ',
      caseSensitive: false,
    );

    final bismillahDisplay = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

    List<InlineSpan> spans = [];

    bool firstAyahHasBismillah = false;
    bool bismillahIsAlone = false;
    String firstAyahTextWithoutBismillah = '';

    if (!isFatiha && ayahs.isNotEmpty) {
      final firstAyahText = ayahs.first.text.trim();

      log('firstAyahText: $firstAyahText');

      firstAyahHasBismillah =
          bismillahRegex.hasMatch(firstAyahText) ||
          firstAyahText.contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ');

      log('firstAyahHasBismillah: $firstAyahHasBismillah');

      if (firstAyahHasBismillah) {
        // حفظ النص بدون البسملة لاستخدامه لاحقاً
        firstAyahTextWithoutBismillah = firstAyahText
            .replaceAll('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '')
            .trim();
        bismillahIsAlone = firstAyahTextWithoutBismillah.isEmpty;

        log('firstAyahTextWithoutBismillah: $firstAyahTextWithoutBismillah');
        log('bismillahIsAlone: $bismillahIsAlone');
      }
    }

    // عرض البسملة منفصلة إذا كانت مدمجة مع نص آخر
    if (!isFatiha && firstAyahHasBismillah && !bismillahIsAlone) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                bismillahDisplay,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.quran,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4A574),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // أضف الآيات
    for (int i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      String ayahText = ayah.text;

      // بالنسبة للآية الأولى: إذا كانت تحتوي على بسملة وغير منفردة، استخدم النص بدون البسملة
      if (!isFatiha && i == 0 && firstAyahHasBismillah && !bismillahIsAlone) {
        ayahText =
            firstAyahTextWithoutBismillah; // استخدم النص المحفوظ بدون البسملة

        // إذا كان النص بدون البسملة فارغاً، تخطى هذه الآية
        if (ayahText.isEmpty) {
          continue;
        }
      }

      // إضافة مفتاح للآية المستهدفة
      final isTargetAyah =
          widget.scrollToAyah != null &&
          ayah.numberInSurah == widget.scrollToAyah;

      if (isTargetAyah) {
        log('Target ayah found: ${ayah.numberInSurah}');
      }

      spans.add(
        TextSpan(
          children: [
            TextSpan(
              text: '$ayahText ',
              recognizer: TapGestureRecognizer()
                ..onTap = () => _showAyahOptionsDialog(context, ayah),
              style: TextStyle(
                backgroundColor: isTargetAyah
                    ? const Color(0xFFD4A574).withOpacity(0.2)
                    : null,
              ),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                key: isTargetAyah ? _ayahKey : null,
                child: GestureDetector(
                  onTap: () => _showAyahOptionsDialog(context, ayah),
                  child: _buildAyahNumber(ayah.numberInSurah),
                ),
              ),
            ),
            const TextSpan(text: ' '),
            // ✅ إضافة الترجمة تحت الآية
            if (ayah.translation != null && ayah.translation!.isNotEmpty)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  width: MediaQuery.of(context).size.width - 32.w,
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFFF5F0E8),
                    borderRadius: BorderRadius.circular(12.h),
                    border: Border(
                      right: BorderSide(
                        color: const Color(0xFFD4A574),
                        width: 3.w,
                      ),
                    ),
                  ),
                  child: Text(
                    ayah.translation!,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.7,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.85)
                          : Colors.black.withOpacity(0.75),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          style: TextStyle(
            fontFamily: AppFonts.quran,
            fontSize: 21.sp,
            height: 1.9,
            color:
                Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          children: spans,
        ),
      ),
    );
  }

  /// ✅ طريقة عرض جديدة للآيات مع الترجمات - كل آية في كتلة منفصلة
  Widget _buildAyahsWithTranslationsLayout(
    BuildContext context,
    List<AyahEntity> ayahs, {
    double? minHeight,
  }) {
    final isFatiha = _surahNumber == 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bismillahRegex = RegExp(
      r'بِسْمِ.*الله.*الرَّحْمَٰنِ.*الرَّحِيمِ',
      caseSensitive: false,
    );

    final bismillahDisplay = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

    bool firstAyahHasBismillah = false;
    bool bismillahIsAlone = false;
    String firstAyahTextWithoutBismillah = '';

    if (!isFatiha && ayahs.isNotEmpty) {
      final firstAyahText = ayahs.first.text.trim();
      firstAyahHasBismillah =
          bismillahRegex.hasMatch(firstAyahText) ||
          firstAyahText.contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ');

      if (firstAyahHasBismillah) {
        firstAyahTextWithoutBismillah = firstAyahText
            .replaceAll('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '')
            .trim();
        bismillahIsAlone = firstAyahTextWithoutBismillah.isEmpty;
      }
    }

    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // البسملة
          if (!isFatiha && firstAyahHasBismillah && !bismillahIsAlone)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Text(
                  bismillahDisplay,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.quran,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4A574),
                  ),
                ),
              ),
            ),

          // الآيات
          ...ayahs.asMap().entries.map((entry) {
            final i = entry.key;
            final ayah = entry.value;
            String ayahText = ayah.text;

            if (!isFatiha &&
                i == 0 &&
                firstAyahHasBismillah &&
                !bismillahIsAlone) {
              ayahText = firstAyahTextWithoutBismillah;
              if (ayahText.isEmpty) return const SizedBox.shrink();
            }

            final isTargetAyah =
                widget.scrollToAyah != null &&
                ayah.numberInSurah == widget.scrollToAyah;

            return Container(
              key: isTargetAyah ? _ayahKey : null,
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isTargetAyah
                    ? const Color(0xFFD4A574).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ النص العربي مع رقم الآية
                  GestureDetector(
                    onTap: () => _showAyahOptionsDialog(context, ayah),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // رقم الآية
                        _buildAyahNumber(ayah.numberInSurah),
                        SizedBox(width: 8.w),
                        // النص العربي
                        Expanded(
                          child: Text(
                            ayahText,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: AppFonts.quran,
                              fontSize: 21.sp,
                              height: 1.8,
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ الترجمة
                  if (ayah.translation != null &&
                      ayah.translation!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : const Color(0xFFF5F0E8),
                        borderRadius: BorderRadius.circular(8.h),
                        border: Border(
                          right: BorderSide(
                            color: const Color(0xFFD4A574),
                            width: 3.w,
                          ),
                        ),
                      ),
                      child: Text(
                        ayah.translation!,
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          height: 1.7,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? Colors.white.withOpacity(0.85)
                              : Colors.black.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVerticalView(List<AyahEntity> ayahs) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            _saveReadingPosition();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmarks_outlined,
              color: Color(0xFFD4A574),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _readingMode == ReadingMode.vertical
                  ? Icons.swap_vert
                  : Icons.swap_horiz,
              color: const Color(0xFFD4A574),
            ),
            onPressed: _showReadingModeDialog,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          // استدعاء الانتقال بعد بناء الإطار
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToTargetAyah();
          });

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeader(),
                _buildAyahsContent(context, ayahs),
                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalView(List<AyahEntity> ayahs) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            _saveReadingPosition();
            Navigator.pop(context);
          },
        ),
        title: BlocBuilder<QuranBloc, QuranState>(
          builder: (context, state) {
            final pageAyahs = _splitAyahsByPage(ayahs);
            final currentPageAyahs = _currentPage < pageAyahs.length
                ? pageAyahs[_currentPage]
                : [];
            final currentPageNumber = currentPageAyahs.isNotEmpty
                ? currentPageAyahs.first.page
                : _currentPage + 1;

            return Text(
              '${localizations?.page ?? 'Page'} $currentPageNumber',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmarks_outlined,
              color: Color(0xFFD4A574),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _readingMode == ReadingMode.vertical
                  ? Icons.swap_vert
                  : Icons.swap_horiz,
              color: const Color(0xFFD4A574),
            ),
            onPressed: _showReadingModeDialog,
          ),
        ],
      ),
      body: BlocBuilder<QuranBloc, QuranState>(
        // Skip rebuilding for tafsir-related states to maintain page position
        buildWhen: (previous, current) {
          if (current is TafsirLoaded) return false;
          if (current is Loading && _cachedAyahs != null) return false;
          return true;
        },
        builder: (context, state) {
          // Use cached ayahs if state is not SurahAyahsLoaded but we have cache
          final ayahsToUse = (state is SurahAyahsLoaded)
              ? state.ayahs
              : _cachedAyahs;

          if (ayahsToUse != null && ayahsToUse.isNotEmpty) {
            final pageAyahs = _splitAyahsByPage(ayahsToUse);

            // الانتقال إلى الصفحة التي تحتوي على الآية المستهدفة
            if (widget.scrollToAyah != null && !_hasJumpedToPage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _jumpToPageWithAyah(pageAyahs, widget.scrollToAyah!);
              });
            }

            // الانتقال إلى الصفحة الأولية (للختمة)
            if (widget.initialPage != null && !_hasJumpedToPage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _jumpToInitialPage(pageAyahs, widget.initialPage!);
              });
            }

            return PageView.builder(
              controller: _pageController,
              reverse: true,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                _saveReadingPosition();

                // Update Khatma Progress only if coming from Khatmah session
                if (widget.isKhatmah &&
                    index < pageAyahs.length &&
                    pageAyahs[index].isNotEmpty) {
                  final currentPageNumber = pageAyahs[index].first.page;
                  final juz = QuranPages.getJuzForPage(currentPageNumber);
                  final hizb = QuranPages.getHizbForPage(currentPageNumber);

                  context.read<KhatmaProgressBloc>().add(
                    UpdateKhatmaProgress(
                      page: currentPageNumber,
                      juz: juz,
                      hizb: hizb,
                    ),
                  );
                }
              },
              itemCount: pageAyahs.length,
              itemBuilder: (context, pageIndex) {
                return _buildPageByPageNumber(
                  context,
                  pageAyahs[pageIndex],
                  pageIndex,
                  MediaQuery.of(context).size.height,
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPageByPageNumber(
    BuildContext context,
    List<AyahEntity> pageAyahs,
    int pageIndex,
    double maxHeight,
  ) {
    // Check if this is the last page of the surah
    final isLastPage =
        pageIndex ==
        (_splitAyahsByPage(
              context.read<QuranBloc>().state is SurahAyahsLoaded
                  ? (context.read<QuranBloc>().state as SurahAyahsLoaded).ayahs
                        .cast<AyahEntity>()
                  : [],
            ).length -
            1);

    return Container(
      height: maxHeight,
      child: Column(
        children: [
          if (pageIndex == 0) _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: _buildAyahsContent(context, pageAyahs, minHeight: null),
              ),
            ),
          ),
          // Add next surah button at the end
          if (isLastPage && _surahNumber < 114)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: ElevatedButton.icon(
                onPressed: () {
                  final nextSurahNumber = _surahNumber + 1;
                  final nextSurahName =
                      QuranPages.surahNames[nextSurahNumber] ?? '';

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahScreen(
                        surahNumber: nextSurahNumber,
                        surahName: nextSurahName,
                        forceHorizontalMode: widget.forceHorizontalMode,
                        isKhatmah: widget.isKhatmah, // Pass the flag
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_back, size: 20.sp),
                label: Text(
                  'السورة التالية: ${QuranPages.surahNames[_surahNumber + 1]}',
                  style: TextStyle(fontSize: 16.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A574),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _jumpToPageWithAyah(List<List<AyahEntity>> pageAyahs, int targetAyah) {
    if (_hasJumpedToPage) return;

    // البحث عن الصفحة التي تحتوي على الآية المستهدفة
    for (int i = 0; i < pageAyahs.length; i++) {
      final ayahsInPage = pageAyahs[i];
      final containsTargetAyah = ayahsInPage.any(
        (ayah) => ayah.numberInSurah == targetAyah,
      );

      if (containsTargetAyah) {
        log('Jumping to page $i for ayah $targetAyah');
        _hasJumpedToPage = true;
        // استخدم Future.delayed لضمان أن PageController جاهز
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(i);
            if (mounted) {
              setState(() {
                _currentPage = i;
              });
            }
          }
        });
        break;
      }
    }
  }

  void _jumpToInitialPage(List<List<dynamic>> pageAyahs, int targetPageNumber) {
    if (_hasJumpedToPage) return;

    // البحث عن الصفحة بناءً على رقم الصفحة
    for (int i = 0; i < pageAyahs.length; i++) {
      final ayahsInPage = pageAyahs[i];
      if (ayahsInPage.isNotEmpty &&
          ayahsInPage.first.page == targetPageNumber) {
        log('Jumping to page index $i for page number $targetPageNumber');
        _hasJumpedToPage = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(i);
            if (mounted) {
              setState(() {
                _currentPage = i;
              });
            }
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final prefs = getIt<SharedPreferences>();
            final reciterId = prefs.getString('selected_reciter_id');
            final language = prefs.getString('language') ?? 'ar';
            return getIt<QuranBloc>()..add(
              GetSurahByNumberEvent(
                number: _surahNumber,
                reciterId: reciterId,
                language: language,
              ),
            );
          },
        ),
        BlocProvider(create: (_) => getIt<SurahDownloadCubit>()),
        BlocProvider(create: (_) => getIt<KhatmaProgressBloc>()),
      ],
      child: BlocConsumer<QuranBloc, QuranState>(
        listener: (context, state) {
          // Cache ayahs when loaded to prevent losing them during tafsir operations
          if (state is SurahAyahsLoaded) {
            _cachedAyahs = state.ayahs;
          }
        },
        // Don't rebuild when tafsir is loading/loaded - only the dialog needs that
        buildWhen: (previous, current) {
          // Skip rebuilding for tafsir-related states
          if (current is TafsirLoaded) return false;
          // Skip rebuilding for Loading state if we already have ayahs cached
          if (current is Loading && _cachedAyahs != null) return false;
          return true;
        },
        builder: (context, state) {
          if (state is Loading) {
            return Scaffold(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xff0a2f45)
                  : const Color(0xFFFAF8F3),
              body: QuranLottieLoading(
                message: localizations?.loading ?? 'Loading...',
              ),
            );
          }
          if (state is Error) {
            return Scaffold(
              body: custom.ErrorWidget(
                message: state.message,
                onRetry: () {
                  final prefs = getIt<SharedPreferences>();
                  final language = prefs.getString('language') ?? 'ar';
                  context.read<QuranBloc>().add(
                    GetSurahByNumberEvent(
                      number: widget.surahNumber!,
                      language: language,
                    ),
                  );
                },
              ),
            );
          }
          if (state is SurahAyahsLoaded) {
            return _readingMode == ReadingMode.vertical
                ? _buildVerticalView(state.ayahs)
                : _buildHorizontalView(state.ayahs);
          }
          return const Scaffold(
            backgroundColor: Color(0xFFFAF8F3),
            body: SizedBox(),
          );
        },
      ),
    );
  }
}
