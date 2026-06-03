import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/back_icon.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:meshkat_elhoda/features/favorites/domain/entities/favorite_item.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/bloc/hadith_bloc.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/bloc/hadith_event.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/bloc/hadith_state.dart';
import 'package:meshkat_elhoda/features/hadith/data/models/hadith_model.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/hadith.dart';

class HadithDetailsPage extends StatefulWidget {
  final String hadithId;
  final String languageCode;

  const HadithDetailsPage({
    super.key,
    required this.hadithId,
    required this.languageCode,
  });

  @override
  State<HadithDetailsPage> createState() => _HadithDetailsPageState();
}

class _HadithDetailsPageState extends State<HadithDetailsPage> {
  late HadithBloc hadithBloc;
  late FavoritesBloc favoritesBloc;
  double fontScale = 1.0;

  @override
  void initState() {
    super.initState();
    hadithBloc = getIt<HadithBloc>();
    favoritesBloc = getIt<FavoritesBloc>();

    // Load hadith details
    hadithBloc.add(
      GetHadithByIdEvent(
        id: widget.hadithId,
        languageCode: widget.languageCode,
      ),
    );

    // Load favorites to check status
    favoritesBloc.add(const LoadFavorites());
  }

  void _shareHadith(BuildContext btnContext, Hadith hadith) async {
    final model = hadith as HadithModel;
    final box = btnContext.findRenderObject() as RenderBox?;
    final rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    // بناء نص المشاركة الكامل
    StringBuffer text = StringBuffer();

    // ═══════════════════════════════════════
    // 📖 نص الحديث
    // ═══════════════════════════════════════
    text.writeln('📖 نص الحديث:');
    text.writeln(hadith.hadithText);
    text.writeln();

    // ═══════════════════════════════════════
    // 👤 الراوي
    // ═══════════════════════════════════════
    if (hadith.narrator.isNotEmpty) {
      text.writeln(
        '👤 ${AppLocalizations.of(context)?.narrator ?? 'الراوي'}: ${hadith.narrator}',
      );
      text.writeln();
    }

    // ═══════════════════════════════════════
    // 📚 المصدر والمرجع
    // ═══════════════════════════════════════
    if (hadith.bookName.isNotEmpty) {
      text.writeln(hadith.bookName);
    }
    if (hadith.chapter.isNotEmpty) {
      text.writeln(hadith.chapter);
    }
    if (hadith.reference.isNotEmpty) {
      text.writeln(
        '🔖 ${AppLocalizations.of(context)?.sourceLabel ?? 'المرجع'}: ${hadith.reference}',
      );
    }
    text.writeln();

    // ═══════════════════════════════════════
    // ⭐ تقييمات العلماء
    // ═══════════════════════════════════════
    if (hadith.grades.isNotEmpty) {
      text.writeln(
        '⭐ ${AppLocalizations.of(context)?.scholarsEvaluation ?? 'تقييمات العلماء'}:',
      );
      for (var grade in hadith.grades) {
        text.writeln('   • ${grade.name}: ${grade.grade}');
      }
      text.writeln();
    }

    // ═══════════════════════════════════════
    // 💡 الشرح
    // ═══════════════════════════════════════
    if (model.explanation != null && model.explanation!.isNotEmpty) {
      text.writeln(
        '💡 ${AppLocalizations.of(context)?.explanation ?? 'الشرح'}:',
      );
      text.writeln(model.explanation);
      text.writeln();
    }

    // ═══════════════════════════════════════
    // 🌟 الفوائد والدروس المستفادة
    // ═══════════════════════════════════════
    if (model.hints != null && model.hints!.isNotEmpty) {
      text.writeln(
        '🌟 ${AppLocalizations.of(context)?.benefits ?? 'الفوائد والدروس المستفادة'}:',
      );
      for (var hint in model.hints!) {
        text.writeln('   • $hint');
      }
      text.writeln();
    }

    // ═══════════════════════════════════════
    // 📖 معاني الكلمات
    // ═══════════════════════════════════════
    if (model.wordsMeaning != null && model.wordsMeaning!.isNotEmpty) {
      text.writeln('📖 معاني الكلمات:');
      for (var wm in model.wordsMeaning!) {
        text.writeln('   • ${wm.word}: ${wm.meaning}');
      }
      text.writeln();
    }

    // ═══════════════════════════════════════
    // 🌙 توقيع التطبيق
    // ═══════════════════════════════════════
    text.writeln('━━━━━━━━━━━━━━━━━━━━');
    text.writeln(
      '🌙 ${AppLocalizations.of(context)?.shareHadithText ?? 'عبر تطبيق مشكاة الهدى'}',
    );

    // مشاركة النص مع اللوجو
    try {
      final byteData = await rootBundle.load('assets/images/icon.png');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/icon.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // مشاركة النص مع الصورة
      await Share.shareXFiles(
        [XFile(file.path)],
        text: text.toString(),
        subject: '📖 حديث شريف',
        sharePositionOrigin: rect,
      );
    } catch (e) {
      // في حالة فشل تحميل اللوجو، شارك النص فقط
      Share.share(text.toString(), sharePositionOrigin: rect);
    }
  }

  void _copyHadith(Hadith hadith) async {
    await Clipboard.setData(ClipboardData(text: hadith.hadithText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.hadithCopied ?? 'تم نسخ الحديث',
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleFavorite(Hadith hadith) {
    final state = favoritesBloc.state;
    final uniqueId = 'hadith_${hadith.id}';

    bool isFav = false;
    if (state is FavoritesLoaded) {
      isFav = state.favorites.any((f) => f.id == uniqueId);
    }

    if (isFav) {
      favoritesBloc.add(RemoveFavorite(itemId: uniqueId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.hadithRemovedFromFavorites ??
                'تم إزالة الحديث من المفضلة',
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final favoriteItem = FavoriteItem(
        id: uniqueId,
        title: hadith.hadithText.length > 50
            ? '${hadith.hadithText.substring(0, 50)}...'
            : hadith.hadithText,
        description: hadith.bookName,
        category: 'حديث',
        createdAt: DateTime.now(),
      );
      favoritesBloc.add(AddFavorite(item: favoriteItem));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.hadithAddedToFavorites ??
                'تم إضافة الحديث للمفضلة',
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.hadithDetails ??
                          'تفاصيل الحديث',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  BackIcon(onTap: () => Navigator.pop(context)),
                  SizedBox(width: 16.w),
                ],
              ),
            ),

            // Content
            Expanded(
              child: BlocBuilder<HadithBloc, HadithState>(
                bloc: hadithBloc,
                builder: (context, state) {
                  if (state is HadithLoading) {
                    return const QuranLottieLoading();
                  }

                  if (state is HadithError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.sp,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16.h),
                          Text(state.message, textAlign: TextAlign.center),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context)?.close ?? 'رجوع',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is HadithLoaded) {
                    return _buildHadithContent(state.hadith);
                  }

                  return const QuranLottieLoading();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithContent(Hadith hadith) {
    final model = hadith as HadithModel;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Font controls
          _buildFontControls(),
          SizedBox(height: 16.h),

          // Main card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.goldenColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Grade badge
                      if (hadith.grades.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getGradeColor(hadith.grades.first.grade),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            hadith.grades.first.grade,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // Hadith ID
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldenColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${hadith.id}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hadith text
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: SelectableText(
                    hadith.hadithText,
                    style: TextStyle(
                      fontSize: 18.sp * fontScale,
                      height: 1.8,
                      fontFamily: 'Amiri',
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),

                // Reference
                if (hadith.reference.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      hadith.reference,
                      style: TextStyle(
                        fontSize: 14.sp * fontScale,
                        color: AppColors.goldenColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                SizedBox(height: 16.h),

                // Action buttons with favorite status
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  bloc: favoritesBloc,
                  builder: (context, favState) {
                    bool isFavorite = false;
                    if (favState is FavoritesLoaded) {
                      final uniqueId = 'hadith_${hadith.id}';
                      isFavorite = favState.favorites.any(
                        (f) => f.id == uniqueId,
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.copy,
                            label: AppLocalizations.of(context)?.copy ?? 'نسخ',
                            onTap: () => _copyHadith(hadith),
                          ),
                          Builder(
                            builder: (btnContext) => _buildActionButton(
                              icon: Icons.share,
                              label:
                                  AppLocalizations.of(context)?.share ?? 'مشاركة',
                              onTap: () => _shareHadith(btnContext, hadith),
                            ),
                          ),
                          _buildActionButton(
                            icon: isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            label:
                                AppLocalizations.of(context)?.favorites ??
                                'مفضلة',
                            onTap: () => _toggleFavorite(hadith),
                            color: isFavorite ? Colors.red : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),

          // Explanation section
          if (model.explanation != null && model.explanation!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildInfoCard(
              title: AppLocalizations.of(context)!.explanation,
              content: model.explanation!,
              icon: Icons.lightbulb_outline,
            ),
          ],

          // Hints/Benefits section
          if (model.hints != null && model.hints!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star_outline,
                          color: AppColors.goldenColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          AppLocalizations.of(context)!.benefits,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldenColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ...model.hints!
                        .map(
                          (hint) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16.sp * fontScale,
                                    color: AppColors.goldenColor,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    hint,
                                    style: TextStyle(
                                      fontSize: 14.sp * fontScale,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ],

          // Word meanings section
          if (model.wordsMeaning != null && model.wordsMeaning!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.book_outlined,
                          color: AppColors.goldenColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          AppLocalizations.of(context)?.wordsMeaning ??
                              'الأحاديث',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldenColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ...model.wordsMeaning!
                        .map(
                          (wm) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldenColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    wm.word,
                                    style: TextStyle(
                                      fontSize: 14.sp * fontScale,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.goldenColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    wm.meaning,
                                    style: TextStyle(
                                      fontSize: 14.sp * fontScale,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildFontControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: fontScale > 0.8
                ? () => setState(() => fontScale -= 0.1)
                : null,
            icon: Icon(
              Icons.zoom_out,
              color: fontScale > 0.8 ? AppColors.goldenColor : Colors.grey,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.goldenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(fontScale * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.goldenColor,
              ),
            ),
          ),
          IconButton(
            onPressed: fontScale < 1.8
                ? () => setState(() => fontScale += 0.1)
                : null,
            icon: Icon(
              Icons.zoom_in,
              color: fontScale < 1.8 ? AppColors.goldenColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final iconColor = color ?? AppColors.goldenColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.goldenColor, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldenColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SelectableText(
              content,
              style: TextStyle(fontSize: 14.sp * fontScale, height: 1.8),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    final lowerGrade = grade.toLowerCase();
    if (lowerGrade.contains('صحيح') || lowerGrade.contains('sahih')) {
      return const Color(0xFF2E7D32);
    } else if (lowerGrade.contains('حسن') || lowerGrade.contains('hasan')) {
      return const Color(0xFFEF6C00);
    } else if (lowerGrade.contains('ضعيف') || lowerGrade.contains('daif')) {
      return const Color(0xFFC62828);
    }
    return const Color(0xFF455A64);
  }
}
