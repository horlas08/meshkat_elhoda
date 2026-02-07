import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required String iconPath,
  TextInputType? keyboardType,
  bool obscureText = false,
  bool isPassword = false,
  required String? Function(String?) validator,
}) {
  bool _obscureText = obscureText;

  return StatefulBuilder(
    builder: (context, setState) {
      return TextFormField(
        controller: controller,
        cursorColor: AppColors.secondaryColor,
        keyboardType: keyboardType,
        obscureText: isPassword ? _obscureText : obscureText,
        style: TextStyle(fontSize: 16.sp, color: AppColors.goldenColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          // إضافة أيقونة SVG
          prefixIcon: Padding(
            padding: const EdgeInsets.all(15.0), // تقليل البادنج حول الأيقونة
            child: SvgPicture.asset(
              iconPath,
              width: 10, // تقليل حجم الأيقونة
              height: 10,
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
          ),
          // إضافة أيقونة العين لحقول كلمة المرور
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          // إزالة البوردر
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          // لون خلفية الحقل
          filled: true,
          fillColor: AppColors.textFieldColor,
          // تقليل الـ contentPadding
          contentPadding: EdgeInsets.symmetric(
            horizontal: 5.w, // تقليل من 16 إلى 12
            vertical: 5.h, // تقليل من 18 إلى 12
          ),
          // تقليل المسافة بين العناصر داخلياً
          isDense: true,
        ),
        validator: validator,
      );
    },
  );
}
