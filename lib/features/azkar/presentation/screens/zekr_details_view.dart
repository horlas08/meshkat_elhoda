import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_state.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/zekr_card.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:meshkat_elhoda/features/favorites/domain/entities/favorite_item.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../l10n/app_localizations.dart';

class ZekrDetailsView extends StatefulWidget {
  final int zekrId; // معامل لـ ID الذكر
  final String categoryTitle; // معامل لعنوان القسم

  const ZekrDetailsView({
    super.key,
    required this.zekrId,
    required this.categoryTitle,
  });

  @override
  State<ZekrDetailsView> createState() => _ZekrDetailsViewState();
}

class _ZekrDetailsViewState extends State<ZekrDetailsView> {
  double fontScale = 1;
  late FavoritesBloc favoritesBloc;

  @override
  void initState() {
    super.initState();
    favoritesBloc = getIt<FavoritesBloc>();
    // جلب تفاصيل الذكر عند فتح الشاشة
    _loadZekrDetails();
    favoritesBloc.add(const LoadFavorites());
  }

  @override
  void dispose() {
    favoritesBloc.close();
    super.dispose();
  }

  void _loadZekrDetails() {
    final languageCode = Localizations.localeOf(context).languageCode;
    context.read<AzkarBloc>().add(FetchAzkarItems(widget.zekrId, languageCode));
  }

  void _copyZekr(String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.copyZekrSuccess,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> shareZekrWithImage(String text) async {
    try {
      // نص المشاركة مع إضافة المعلومات
      final shareText =
          '${AppLocalizations.of(context)!.zekrShared}: ${AppLocalizations.of(context)!.appTitle}\n\n$text';

      // تحميل صورة اللوجو من الـ assets إلى مجلد مؤقت
      final byteData = await rootBundle.load('assets/images/icon.png');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/icon.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // مشاركة النص مع صورة اللوجو
      await Share.shareXFiles([XFile(file.path)], text: shareText);
    } catch (e) {
      print('خطأ في المشاركة مع صورة: $e');
      // المشاركة بالنص فقط لو فشل تحميل الصورة
      await Share.share(
        '${AppLocalizations.of(context)!.zekrShared}: ${AppLocalizations.of(context)!.appTitle}\n\n$text',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: favoritesBloc)],
      child: Scaffold(
        body: BlocBuilder<AzkarBloc, AzkarState>(
          builder: (context, state) {
            // حالة التحميل
            if (state is AzkarLoading) {
              return _buildLoadingState();
            }

            // حالة الخطأ
            if (state is AzkarError) {
              return _buildErrorState(state.message);
            }

            // حالة نجاح تحميل العناصر
            if (state is AzkarItemsLoaded) {
              return _buildSuccessState(state.items);
            }

            // الحالة الابتدائية
            return _buildLoadingState();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: QuranLottieLoading());
  }

  Widget _buildErrorState(String errorMessage) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            children: [
              IslamicAppbar(
                title: widget.categoryTitle,
                onTap: () => Navigator.pop(context),
              ),
              SizedBox(height: 23.h),
              Center(
                child: Text(
                  '${AppLocalizations.of(context)!.loadDataError}: $errorMessage',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState(List<Azkar> items) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, favoritesState) {
        List<FavoriteItem> favorites = [];
        if (favoritesState is FavoritesLoaded) {
          favorites = favoritesState.favorites;
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IslamicAppbar(
                    title: widget.categoryTitle,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 23.h),

                  // Font size controls
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
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
                            color: fontScale > 0.8
                                ? AppColors.goldenColor
                                : AppColors.goldenColor,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
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
                            color: fontScale < 1.8
                                ? AppColors.goldenColor
                                : AppColors.goldenColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 23.h),

                  // عرض كل الأذكار في هذه الفئة
                  ...items.map((zekr) {
                    final uniqueId = 'zekr_${widget.zekrId}_${zekr.id}';
                    final isFavorite = favorites.any((f) => f.id == uniqueId);

                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: ZekrCard(
                        zekrText: zekr.text,
                        isFavorite: isFavorite,
                        onFavorite: () {
                          if (isFavorite) {
                            context.read<FavoritesBloc>().add(
                              RemoveFavorite(itemId: uniqueId),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.removeFromFavorites,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            final favoriteItem = FavoriteItem(
                              id: uniqueId,
                              title: zekr.text.length > 50
                                  ? '${zekr.text.substring(0, 50)}...'
                                  : zekr.text,
                              description: widget.categoryTitle,
                              category: 'ذكر',
                              createdAt: DateTime.now(),
                            );
                            context.read<FavoritesBloc>().add(
                              AddFavorite(item: favoriteItem),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.addToFavoritesSuccess,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        onShare: () {
                          final text =
                              '''
${zekr.text}

${widget.categoryTitle}
${zekr.repeat != null ? '${AppLocalizations.of(context)!.repeat}: ${zekr.repeat}' : ''}
''';
                          shareZekrWithImage(text);
                        },
                        onCoppy: () {
                          final text =
                              '''
${zekr.text}

${widget.categoryTitle}
${zekr.repeat != null ? '${AppLocalizations.of(context)!.repeat}: ${zekr.repeat}' : ''}
''';
                          _copyZekr(text);
                        },
                        repeat: zekr.repeat ?? 1,
                        fontScale: fontScale,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
