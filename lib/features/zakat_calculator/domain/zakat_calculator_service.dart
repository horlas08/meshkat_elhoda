import 'dart:math';

class ZakatCalculationResult {
  final double totalAmount;
  final double? zakatAmount;
  final bool isBelowNisaab;
  final String message;

  const ZakatCalculationResult({
    required this.totalAmount,
    required this.zakatAmount,
    required this.isBelowNisaab,
    required this.message,
  });
}

class ZakatCalculatorService {
  /// يحسب الزكاة بناءً على المدخلات المعطاة.
  ///
  /// [cash] إجمالي المال النقدي.
  /// [goldValue] قيمة الذهب مباشرة (إذا لم تُستخدم الغرامات)، يمكن أن تكون 0.
  /// [goldWeightInGrams] عدد غرامات الذهب (اختياري).
  /// [goldPricePerGram24] سعر جرام الذهب عيار 24 (اختياري ولكنه مطلوب إذا فُعل النصاب
  /// أو تم استخدام الغرامات بدلاً من القيمة المباشرة).
  /// [tradeValue] قيمة عروض التجارة.
  /// [enableNisaab] هل يتم تفعيل شرط النصاب أم لا.
  ZakatCalculationResult calculateZakat({
    required double cash,
    required double goldValue,
    double? goldWeightInGrams,
    double? goldPricePerGram24,
    required double tradeValue,
    required bool enableNisaab,
  }) {
    double effectiveGoldValue = goldValue;

    // إذا تم إدخال عدد غرامات الذهب، نستخدمه مع سعر الجرام إن توفر
    if (goldWeightInGrams != null && goldWeightInGrams > 0) {
      if (goldPricePerGram24 == null || goldPricePerGram24 <= 0) {
        throw ArgumentError('سعر جرام الذهب مطلوب عند استخدام عدد الغرامات.');
      }
      effectiveGoldValue = goldWeightInGrams * goldPricePerGram24;
    }

    // مجموع المال
    final total =
        max(0.0, cash) + max(0.0, effectiveGoldValue) + max(0.0, tradeValue);

    if (total == 0) {
      return const ZakatCalculationResult(
        totalAmount: 0,
        zakatAmount: 0,
        isBelowNisaab: true,
        message: 'لم يتم إدخال أي مبالغ تُذكر لحساب الزكاة.',
      );
    }

    if (!enableNisaab) {
      final zakat = total * 0.025;
      return ZakatCalculationResult(
        totalAmount: total,
        zakatAmount: zakat,
        isBelowNisaab: false,
        message:
            'مجموع المال: ${total.toStringAsFixed(2)}\nمقدار الزكاة الواجبة: ${zakat.toStringAsFixed(2)}\n(٢.٥٪ من المبلغ)',
      );
    }

    // تفعيل النصاب يتطلب وجود سعر جرام الذهب
    // تحديث: إذا لم يتم إدخال سعر الذهب، نقوم بالحساب مع التنبيه بدلا من رمي الخطأ
    double? nisaab;
    if (goldPricePerGram24 != null && goldPricePerGram24 > 0) {
      nisaab = 85.0 * goldPricePerGram24;
    }

    if (enableNisaab && nisaab != null) {
      if (total < nisaab) {
        return ZakatCalculationResult(
          totalAmount: total,
          zakatAmount: null,
          isBelowNisaab: true,
          message:
              'الغالب أنه لا تجب عليك الزكاة الآن لأن المبلغ أقل من النصاب (${nisaab.toStringAsFixed(2)}).\nيُرجى سؤال أحد أهل العلم للمزيد من التأكد.',
        );
      }
    }

    final zakat = total * 0.025;

    String message =
        'مجموع المال: ${total.toStringAsFixed(2)}\nمقدار الزكاة الواجبة: ${zakat.toStringAsFixed(2)}\n(٢.٥٪ من المبلغ)';

    if (enableNisaab && nisaab == null) {
      message +=
          '\n\n* تنبيه: لم يتم التحقق من النصاب لعدم إدخال سعر جرام الذهب.';
    }

    return ZakatCalculationResult(
      totalAmount: total,
      zakatAmount: zakat,
      isBelowNisaab: false,
      message: message,
    );
  }
}
