import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/custom_snack_bar.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_event.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_state.dart';
import 'package:meshkat_elhoda/features/auth/presentation/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetEmailSent) {
          ModernSnackBar.show(
            context: context,
            message: state.message,
            type: SnackBarType.success,
            duration: const Duration(seconds: 4),
          );
          // العودة إلى صفحة تسجيل الدخول بعد ثانيتين
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else if (state is AuthError) {
          ModernSnackBar.show(
            context: context,
            message: state.message,
            type: SnackBarType.error,
            duration: const Duration(seconds: 4),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: AppColors.goldenColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 60.sp,
                        color: AppColors.goldenColor,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Title
                    Text(
                      AppLocalizations.of(context)!.forgotPasswordTitle,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenColor,
                        fontFamily: AppFonts.tajawal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),

                    // Description
                    Text(
                      AppLocalizations.of(context)!.forgotPasswordDescription,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.secondaryColor,
                        fontFamily: AppFonts.tajawal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),

                    // Email Field
                    buildTextField(
                      iconPath: 'assets/icons/email.svg',
                      controller: _emailController,
                      label: AppLocalizations.of(context)!.emailLabel,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.emailRequiredError;
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return AppLocalizations.of(
                            context,
                          )!.invalidEmailError;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.h),

                    // Submit Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is ResetPasswordLoading;

                        return SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        ResetPasswordRequested(
                                          _emailController.text.trim(),
                                          context,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLoading
                                  ? Colors.grey[400]
                                  : AppColors.buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.h),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.sendResetLink,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: AppFonts.tajawal,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Back to Login
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        AppLocalizations.of(context)!.backToLogin,
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.tajawal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
