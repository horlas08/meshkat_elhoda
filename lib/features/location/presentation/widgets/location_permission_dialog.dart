import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_bloc.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_event.dart';
import 'package:meshkat_elhoda/features/location/presentation/widgets/manual_location_dialog.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Text(
        'تم رفض إذن الموقع',
        style: AppTextStyles.surahName.copyWith(
          fontFamily: AppFonts.tajawal,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off,
            size: 64.sp,
            color: Colors.orange,
          ),
          SizedBox(height: 16.h),
          Text(
            'لعرض أوقات الصلاة الدقيقة، نحتاج إلى موقعك. يمكنك:',
            style: TextStyle(
              fontFamily: AppFonts.tajawal,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            '• السماح بالوصول إلى الموقع\n• إدخال المدينة والدولة يدوياً',
            style: TextStyle(
              fontFamily: AppFonts.tajawal,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => const ManualLocationDialog(),
            );
          },
          child: Text(
            'إدخال يدوي',
            style: TextStyle(
              fontFamily: AppFonts.tajawal,
              fontSize: 14.sp,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<LocationBloc>().add(RequestLocationPermissionEvent());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'السماح بالموقع',
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
