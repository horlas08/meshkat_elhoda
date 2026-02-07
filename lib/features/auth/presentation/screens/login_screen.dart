import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/custom_snack_bar.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_event.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_state.dart';
import 'package:meshkat_elhoda/features/auth/presentation/screens/register_screen.dart';
import 'package:meshkat_elhoda/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:meshkat_elhoda/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/views/main_navigation_views.dart';

import '../../../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a key to track the last shown message
    String? _lastMessage;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        // Listen to Authenticated, AuthError, and AuthSuccess states
        if (current is Authenticated) {
          return true; // Always navigate when authenticated
        }
        if (current is AuthError || current is AuthSuccess) {
          final currentMessage = current is AuthError
              ? current.message
              : (current as AuthSuccess).message;
          if (_lastMessage != currentMessage) {
            _lastMessage = currentMessage;
            return true;
          }
        }
        return false;
      },
      listener: (context, state) async {
        if (!mounted) return;

        if (state is AuthError) {
          _lastMessage = state.message;
          log(_lastMessage!);

          ModernSnackBar.show(
            context: context,
            message: _lastMessage ?? AppLocalizations.of(context)!.errorMessage,
            type: SnackBarType.error,
            duration: const Duration(seconds: 5),
          );
        } else if (state is AuthSuccess) {
          _lastMessage = state.message;

          if (mounted) {
            ModernSnackBar.show(
              context: context,
              message: _lastMessage!,
              type: SnackBarType.success,
              duration: const Duration(seconds: 2),
            );

            await Future.delayed(const Duration(seconds: 2));

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationViews(),
                ),
              );
            }
          }
        } else if (state is Authenticated) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MainNavigationViews(),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 300.w, // Responsive width
                        height: 300.h, // Responsive height
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 40.h),
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
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    buildTextField(
                      iconPath: 'assets/icons/password.svg',
                      controller: _passwordController,
                      label: AppLocalizations.of(context)!.passwordLabel,
                      obscureText: true,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.passwordRequiredError;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.h),
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.forgotPassword,
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 48.h,
                              child: ElevatedButton(
                                onPressed:
                                    (state is SignInLoading ||
                                        state is SignUpLoading ||
                                        state is GuestSignInLoading)
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<AuthBloc>().add(
                                            SignInRequested(
                                              _emailController.text,
                                              _passwordController.text,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      (state is SignInLoading ||
                                          state is SignUpLoading ||
                                          state is GuestSignInLoading)
                                      ? Colors.grey[400]
                                      : AppColors.buttonColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.h),
                                  ),
                                  elevation: 0,
                                ),
                                child: state is SignInLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.loginButton,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: AppLocalizations.of(
                                          context,
                                        )!.alreadyHaveAccount,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.sp,
                                          fontFamily: AppFonts.tajawal,
                                        ),
                                      ),
                                      TextSpan(
                                        text: AppLocalizations.of(
                                          context,
                                        )!.createAccountLink,
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
                        );
                      },
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
