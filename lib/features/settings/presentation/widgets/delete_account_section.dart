import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_event.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_state.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class DeleteAccountSection extends StatefulWidget {
  const DeleteAccountSection({super.key});

  @override
  State<DeleteAccountSection> createState() => _DeleteAccountSectionState();
}

class _DeleteAccountSectionState extends State<DeleteAccountSection> {
  bool _isDeleting = false;

  void _showDeleteConfirmationDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : AppColors.whiteColor,
        title: Text(
          s.deleteAccountWarning,
          style: AppTextStyles.surahName.copyWith(
            fontFamily: AppFonts.tajawal,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.areYouSureDeleteAccount,
                style: AppTextStyles.surahName.copyWith(
                  fontFamily: AppFonts.tajawal,
                  fontSize: 14.sp,
                  color: isDarkMode
                      ? AppColors.whiteColor
                      : AppColors.blacColor,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.deleteAccountConsequences,
                      style: AppTextStyles.surahName.copyWith(
                        fontFamily: AppFonts.tajawal,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildWarningItem(s.allPersonalDataDeleted),
                    _buildWarningItem(s.activeSubscriptionCancelled),
                    _buildWarningItem(s.actionCannotUndone),
                    _buildWarningItem(s.needNewAccountToUseApp),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isDeleting ? null : () => Navigator.pop(dialogContext),
            child: Text(
              s.cancel,
              style: AppTextStyles.surahName.copyWith(
                fontFamily: AppFonts.tajawal,
                fontSize: 14.sp,
                color: isDarkMode ? AppColors.whiteColor : AppColors.blacColor,
              ),
            ),
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      s.deleteAccountSuccess,
                      style: AppTextStyles.surahName.copyWith(
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
                // العودة للشاشة الرئيسية أو شاشة تسجيل الدخول
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              } else if (state is AuthError) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      s.errorOccurred,
                      style: AppTextStyles.surahName.copyWith(
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: TextButton(
              onPressed: _isDeleting
                  ? null
                  : () {
                      setState(() {
                        _isDeleting = true;
                      });
                      context.read<AuthBloc>().add(
                        const DeleteAccountRequested(),
                      );
                    },
              child: Text(
                _isDeleting ? s.deleting : s.deleteAccount,
                style: AppTextStyles.surahName.copyWith(
                  fontFamily: AppFonts.tajawal,
                  fontSize: 14.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.surahName.copyWith(
                fontFamily: AppFonts.tajawal,
                fontSize: 12.sp,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.whiteColor : AppColors.blacColor;
    final s = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      color: Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.delete_forever, color: Colors.red, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.deleteAccount,
                        style: AppTextStyles.surahName.copyWith(
                          fontFamily: AppFonts.tajawal,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        s.deleteAccountAndAssociatedData,
                        style: AppTextStyles.surahName.copyWith(
                          fontFamily: AppFonts.tajawal,
                          fontSize: 12.sp,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isDeleting
                    ? null
                    : () => _showDeleteConfirmationDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.red.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthError && _isDeleting) {
                      _isDeleting = false;
                    }
                    return Text(
                      s.deleteAccount,
                      style: AppTextStyles.surahName.copyWith(
                        fontFamily: AppFonts.tajawal,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
