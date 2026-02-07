import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/date_conversion_service.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class DateConverterView extends StatefulWidget {
  const DateConverterView({super.key});

  @override
  State<DateConverterView> createState() => _DateConverterViewState();
}

class _DateConverterViewState extends State<DateConverterView> {
  final _dateConversionService = DateConversionService();
  final _hijriController = TextEditingController();

  String? gregorianResult;
  String? hijriResult;

  @override
  void dispose() {
    _hijriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xff0a2f45)
          : AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.dateConverter,
          style: TextStyle(
            fontFamily: AppFonts.tajawal,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gregorian -> Hijri Section
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.gregorianToHijri,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.tajawal,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldenColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: theme.copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.goldenColor,
                                  onPrimary: Colors.white,
                                  surface: isDark
                                      ? const Color(0xff0a2f45)
                                      : Colors.white,
                                  onSurface: isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          final formatted =
                              '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                          try {
                            final result = await _dateConversionService
                                .convertGregorianToHijri(formatted);
                            setState(() {
                              gregorianResult =
                                  '${AppLocalizations.of(context)!.dateGregorianLabel}: ${result.inputDate}\n${AppLocalizations.of(context)!.dateHijriLabel}: ${result.outputDate}';
                            });
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.errorConvertingGregorianToHijri,
                                    style: TextStyle(
                                      fontFamily: AppFonts.tajawal,
                                    ),
                                  ),
                                  backgroundColor: Colors.red.shade500,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.selectGregorianDate,
                        style: TextStyle(
                          fontFamily: AppFonts.tajawal,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (gregorianResult != null) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.withOpacity(0.1)
                              : const Color(0xFFFAF8F3),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.goldenColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          gregorianResult!,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: AppFonts.tajawal,
                            fontSize: 14.sp,
                            height: 1.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Hijri -> Gregorian Section
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.hijriToGregorian,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.tajawal,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppLocalizations.of(context)!.enterHijriDate,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: AppFonts.tajawal,
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _hijriController,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_DateInputFormatter()],
                      style: TextStyle(
                        fontFamily: AppFonts.tajawal,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: AppColors.goldenColor,
                          ),
                        ),
                        isDense: true,
                        hintText: AppLocalizations.of(
                          context,
                        )!.hijriDateExample,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                      onSubmitted: (value) => _convertHijriToGregorian(),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldenColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: _convertHijriToGregorian,
                      child: Text(
                        AppLocalizations.of(context)!.convert,
                        style: TextStyle(
                          fontFamily: AppFonts.tajawal,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (hijriResult != null) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.withOpacity(0.1)
                              : const Color(0xFFFAF8F3),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.goldenColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          hijriResult!,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: AppFonts.tajawal,
                            fontSize: 14.sp,
                            height: 1.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _convertHijriToGregorian() async {
    final trimmed = _hijriController.text.trim();
    if (trimmed.isEmpty) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    try {
      final result = await _dateConversionService.convertHijriToGregorian(
        trimmed,
      );
      setState(() {
        hijriResult = AppLocalizations.of(
          context,
        )!.hijriToGregorianResult(result.inputDate, result.outputDate);
      });
    } catch (e) {
      developer.log(
        'Error converting Hijri date: $e',
        name: 'DateConverterView',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorConvertingHijriDate,
              style: TextStyle(fontFamily: AppFonts.tajawal),
            ),
            backgroundColor: Colors.red.shade500,
          ),
        );
      }
    }
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 8) text = text.substring(0, 8); // Max 8 digits: DDMMYYYY

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }

    var string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
