import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/back_icon.dart';
import 'package:meshkat_elhoda/features/zakat_calculator/domain/zakat_calculator_service.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cashController = TextEditingController();
  final _goldValueController = TextEditingController();
  final _goldWeightController = TextEditingController();
  final _goldPriceController = TextEditingController();
  final _tradeController = TextEditingController();

  bool _enableNisaab = true;
  bool _hasGold = false;
  String? _resultMessage;
  bool _showResult = false;

  final _service = ZakatCalculatorService();

  @override
  void dispose() {
    _cashController.dispose();
    _goldValueController.dispose();
    _goldWeightController.dispose();
    _goldPriceController.dispose();
    _tradeController.dispose();
    super.dispose();
  }

  double _parseOrZero(String value) {
    if (value.trim().isEmpty) return 0;
    return double.tryParse(value.replaceAll(',', '')) ?? 0;
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _showResult = false;
      });
      return;
    }

    final cash = _parseOrZero(_cashController.text);
    final goldValue = _hasGold ? _parseOrZero(_goldValueController.text) : 0.0;
    final goldWeight =
        (_hasGold && _goldWeightController.text.trim().isNotEmpty)
        ? _parseOrZero(_goldWeightController.text)
        : null;

    final isGoldPriceVisible = _hasGold || _enableNisaab;
    final goldPrice =
        (isGoldPriceVisible && _goldPriceController.text.trim().isNotEmpty)
        ? _parseOrZero(_goldPriceController.text)
        : null;

    final trade = _parseOrZero(_tradeController.text);

    try {
      final result = _service.calculateZakat(
        cash: cash,
        goldValue: goldValue,
        goldWeightInGrams: goldWeight,
        goldPricePerGram24: goldPrice,
        tradeValue: trade,
        enableNisaab: _enableNisaab,
      );

      setState(() {
        _resultMessage = result.message;
        _showResult = true;
      });
    } on ArgumentError catch (e) {
      setState(() {
        _showResult = false;
        _resultMessage = e.message?.toString() ?? e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_resultMessage ?? ''),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Directionality(
          textDirection: TextDirection.ltr,
          child: Transform.scale(
            scale: 0.7,
            child: BackIcon(onTap: () => Navigator.pop(context)),
          ),
        ),

        title: Text(
          s.zakatCalculator,
          style: AppTextStyles.surahName.copyWith(
            color: theme.textTheme.bodyLarge?.color ?? AppColors.darkGrey,
            fontFamily: AppFonts.tajawal,
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.zakatDisclaimer,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.surahName.copyWith(
                    fontSize: 12.sp,
                    color:
                        theme.textTheme.bodyMedium?.color ?? Colors.grey[600],
                    fontFamily: AppFonts.tajawal,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildNumberField(
                  label: s.totalCash,
                  controller: _cashController,
                  isRequired: true,
                ),

                SizedBox(height: 12.h),

                // تبديل "هل تملك ذهباً؟"
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          s.doYouOwnGold,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: AppTextStyles.surahName.copyWith(
                            fontSize: 14.sp,
                            color:
                                theme.textTheme.bodyLarge?.color ??
                                AppColors.darkGrey,
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                      ),
                      Switch(
                        value: _hasGold,
                        activeColor: AppColors.goldenColor,
                        onChanged: (value) {
                          setState(() {
                            _hasGold = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                if (_hasGold) ...[
                  SizedBox(height: 12.h),
                  _buildNumberField(
                    label: s.goldValue,
                    controller: _goldValueController,
                    isRequired: false,
                  ),
                  SizedBox(height: 12.h),
                  _buildNumberField(
                    label: s.goldGrams,
                    controller: _goldWeightController,
                    isRequired: false,
                  ),
                ],

                // حقل سعر الجرام يظهر إذا كان الذهب مفعلاً (لحساب القيم) أو النصاب مفعلاً (للمقارنة)
                if (_hasGold || _enableNisaab) ...[
                  SizedBox(height: 12.h),
                  _buildNumberField(
                    label: s.gold24kPrice,
                    controller: _goldPriceController,
                    isRequired: false,
                    helper: _enableNisaab
                        ? s.requiredForNisaab
                        : s.requiredForGoldValue,
                  ),
                ],

                SizedBox(height: 12.h),
                _buildNumberField(
                  label: s.tradeValue,
                  controller: _tradeController,
                  isRequired: true,
                ),
                SizedBox(height: 16.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        s.enableNisaab,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: AppTextStyles.surahName.copyWith(
                          fontSize: 14.sp,
                          fontFamily: AppFonts.tajawal,
                          color:
                              theme.textTheme.bodyLarge?.color ??
                              AppColors.darkGrey,
                        ),
                      ),
                    ),
                    Switch(
                      value: _enableNisaab,
                      activeColor: AppColors.goldenColor,
                      onChanged: (value) {
                        setState(() {
                          _enableNisaab = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldenColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: _calculate,
                    child: Text(
                      s.calculateZakat,
                      style: AppTextStyles.surahName.copyWith(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                if (_showResult && _resultMessage != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? theme.cardColor
                          : const Color(0xFFFAF8F3),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.goldenColor.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      _resultMessage!,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.surahName.copyWith(
                        fontSize: 14.sp,
                        color:
                            theme.textTheme.bodyLarge?.color ??
                            AppColors.darkGrey,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required bool isRequired,
    String? helper,
  }) {
    final theme = Theme.of(context);
    final s = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.surahName.copyWith(
            fontSize: 14.sp,
            color: theme.textTheme.bodyLarge?.color ?? AppColors.darkGrey,
            fontFamily: AppFonts.tajawal,
          ),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            helperText: helper,
          ),
          validator: (value) {
            if (isRequired) {
              if (value == null || value.trim().isEmpty) {
                return s.fieldRequired;
              }
              final parsed = double.tryParse(value.replaceAll(',', ''));
              if (parsed == null || parsed < 0) {
                return s.enterValidNumber;
              }
            } else {
              if (value != null && value.trim().isNotEmpty) {
                final parsed = double.tryParse(value.replaceAll(',', ''));
                if (parsed == null || parsed < 0) {
                  return s.enterValidNumber;
                }
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
