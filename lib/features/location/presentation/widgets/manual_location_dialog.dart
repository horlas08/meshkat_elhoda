import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_bloc.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_event.dart';

class ManualLocationDialog extends StatefulWidget {
  const ManualLocationDialog({super.key});

  @override
  State<ManualLocationDialog> createState() => _ManualLocationDialogState();
}

class _ManualLocationDialogState extends State<ManualLocationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Text(
        'أدخل موقعك يدوياً',
        style: AppTextStyles.surahName.copyWith(
          fontFamily: AppFonts.tajawal,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'المدينة',
                labelStyle: TextStyle(
                  fontFamily: AppFonts.tajawal,
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                fontFamily: AppFonts.tajawal,
                fontSize: 16.sp,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال المدينة';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'الدولة',
                labelStyle: TextStyle(
                  fontFamily: AppFonts.tajawal,
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                fontFamily: AppFonts.tajawal,
                fontSize: 16.sp,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الدولة';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'إلغاء',
            style: TextStyle(
              fontFamily: AppFonts.tajawal,
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<LocationBloc>().add(
                    SetManualLocation(
                      city: _cityController.text.trim(),
                      country: _countryController.text.trim(),
                    ),
                  );
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'تأكيد',
            style: TextStyle(
              fontFamily: AppFonts.tajawal,
              fontSize: 14.sp,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
