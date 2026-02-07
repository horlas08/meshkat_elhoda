import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/custom_snack_bar.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_event.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_state.dart';
import 'package:meshkat_elhoda/features/auth/presentation/screens/login_screen.dart';
import 'package:meshkat_elhoda/features/auth/presentation/widgets/searchable_dropdown.dart';
import 'package:meshkat_elhoda/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/views/home_view.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../main_navigation/presentation/views/main_navigation_views.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedCountry = 'مصر';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (!mounted) return;

          if (state is AuthError) {
            ModernSnackBar.show(
              context: context,
              message: state.message,
              type: SnackBarType.error,
              duration: const Duration(seconds: 3),
            );
          } else if (state is Authenticated || state is AuthSuccess) {
            // Navigate directly to home screen for both regular and guest users
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MainNavigationViews(),
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 200.w, // Responsive width
                      height: 200.h, // Responsive height
                      fit: BoxFit.contain,
                    ),
                  ),
                  // حقل الاسم
                  buildTextField(
                    iconPath: 'assets/icons/user.svg',
                    controller: _nameController,
                    label: AppLocalizations.of(context)!.nameLabel,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.nameRequiredError;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),

                  // حقل البريد الإلكتروني
                  buildTextField(
                    iconPath: 'assets/icons/email.svg',
                    controller: _emailController,
                    label: AppLocalizations.of(context)!.emailLabelRegister,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emailRequiredErrorRegister;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),

                  // حقل كلمة المرور
                  buildTextField(
                    iconPath: 'assets/icons/password.svg',
                    controller: _passwordController,
                    label: AppLocalizations.of(context)!.passwordLabelRegister,
                    obscureText: true,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.passwordRequiredErrorRegister;
                      }
                      if (value.length < 6) {
                        return AppLocalizations.of(context)!.passwordMinLengthError;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),

                  // حقل تأكيد كلمة المرور
                  buildTextField(
                    iconPath: 'assets/icons/password.svg',
                    controller: _confirmPasswordController,
                    label: AppLocalizations.of(context)!.confirmPasswordLabel,
                    obscureText: true,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.confirmPasswordRequiredError;
                      }
                      if (value != _passwordController.text) {
                        return AppLocalizations.of(context)!.passwordsMismatchError;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),

                  const SizedBox(height: 32),

                  // زر إنشاء الحساب
                  Column(
                    children: [
                      // زر الدخول
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed:
                              (state is SignUpLoading ||
                                  state is GuestSignInLoading)
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      SignUpRequested(
                                        name: _nameController.text,
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                        language: Localizations.localeOf(
                                          context,
                                        ).languageCode,
                                        country: _selectedCountry!,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (state is SignUpLoading ||
                                    state is GuestSignInLoading)
                                ? Colors.grey[400]
                                : AppColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.h),
                            ),
                            elevation: 0,
                          ),
                          child: state is SignUpLoading
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
                            AppLocalizations.of(context)!.createAccountButton,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // نص "أو"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.grey, thickness: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppLocalizations.of(context)!.orText,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Colors.grey, thickness: 1),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed:
                              state is SignUpLoading ||
                                  state is GuestSignInLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                    RegisterAsGuestRequested(),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (state is SignUpLoading ||
                                    state is GuestSignInLoading)
                                ? Colors.grey[200]
                                : Colors.white,
                            side: BorderSide(
                              color:
                                  (state is SignUpLoading ||
                                      state is GuestSignInLoading)
                                  ? Colors.grey[300]!
                                  : Colors.blue[700]!,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.h),
                            ),
                            elevation: 0,
                          ),
                          child: state is GuestSignInLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 24,
                                      color:
                                          state is SignUpLoading ||
                                              state is GuestSignInLoading
                                          ? Colors.grey[400]
                                          : Colors.blue[700],
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppLocalizations.of(context)!.loginAsGuestButton,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color:
                                            state is SignUpLoading ||
                                                state is GuestSignInLoading
                                            ? Colors.grey[400]
                                            : Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // رابط تسجيل الدخول
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:  AppLocalizations.of(context)!.noAccountText,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16.sp,
                                    fontFamily: AppFonts.tajawal,
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.loginLinkText,
                                  style: TextStyle(
                                    color: AppColors.secondaryColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppFonts.tajawal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GuestButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GuestButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[700],
          elevation: 8,
          shadowColor: Colors.blue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.h),
            side: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 24, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.loginAsGuestButton,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
