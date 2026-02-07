import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class RamadanGreetingCard extends StatefulWidget {
  const RamadanGreetingCard({super.key});

  @override
  State<RamadanGreetingCard> createState() => _RamadanGreetingCardState();
}

class _RamadanGreetingCardState extends State<RamadanGreetingCard> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareCard() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      // التقاط صورة للكارد
      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        setState(() => _isSharing = false);
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // حفظ الصورة مؤقتاً
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/ramadan_greeting.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // مشاركة الصورة
      await Share.shareXFiles([
        XFile(imagePath),
      ], text: 'رمضان مبارك 🌙\nمن تطبيق مشكاة الهدى برو');
    } catch (e) {
      debugPrint('Error sharing card: $e');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Stack(
      children: [
        // الكارد القابل للمشاركة
        RepaintBoundary(
          key: _cardKey,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xff0475b1).withOpacity(.25),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // لوجو التطبيق
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(
                        AppAssets.appLogo,
                        width: 40.w,
                        height: 40.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: AppColors.goldenColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.auto_stories,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "مشكاة الهدى برو",
                          style: AppTextStyles.zekr.copyWith(
                            color: AppColors.goldenColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Meshkat Elhoda Pro",
                          style: AppTextStyles.zekr.copyWith(
                            color: AppColors.whiteColor.withOpacity(0.7),
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  localizations?.ramadanKarimGreeting ??
                      "رمضان مبارك\nكل عام وأنتم بخير",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.zekr.copyWith(
                    color: AppColors.goldenColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  localizations?.ramadanMubarakFull ??
                      "رمضان مبارك، أعاده الله علينا وعليكم باليمن والبركات",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.zekr.copyWith(
                    color: AppColors.whiteColor.withOpacity(0.8),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        // زر المشاركة
        Positioned(
          top: 20.h,
          right: 20.w,
          child: InkWell(
            onTap: _shareCard,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldenColor.withOpacity(0.2),
              ),
              child: _isSharing
                  ? SizedBox(
                      width: 22.sp,
                      height: 22.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.goldenColor,
                      ),
                    )
                  : Icon(
                      Icons.share,
                      color: AppColors.goldenColor,
                      size: 22.sp,
                    ),
            ),
          ),
        ),

        // صورة الزينة
        PositionedDirectional(
          end: 14.w,
          top: 12.h,
          child: Opacity(
            opacity: 0.85,
            child: Image.asset(
              AppAssets.zena,
              height: 90.h,
              width: 90.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
