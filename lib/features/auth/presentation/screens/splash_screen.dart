import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_preferences.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_event.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_state.dart';
import 'package:meshkat_elhoda/features/auth/presentation/screens/login_screen.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/views/home_view.dart';
import 'package:meshkat_elhoda/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isOnboardingCompleted = await AppPreferences.isOnboardingCompleted();

    if (!isOnboardingCompleted) {
      // Show onboarding for first-time users
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } else {
      // Check authentication status for returning users
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeView()),
          );
        } else if (state is Unauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: const Scaffold(body: Center(child: QuranLottieLoading())),
    );
  }
}
