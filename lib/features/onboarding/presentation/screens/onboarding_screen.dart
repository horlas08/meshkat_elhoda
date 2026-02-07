import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/auth/presentation/screens/login_screen.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      description: 'onboarding_description_1',
      image: 'assets/images/onboarding1.jpg',
    ),
    OnboardingPage(
      description: 'onboarding_description_2',
      image: 'assets/images/onboarding2.jpg',
    ),
    OnboardingPage(
      description: 'onboarding_description_3',
      image: 'assets/images/onboarding3.jpg',
    ),
    OnboardingPage(
      description: 'onboarding_description_4',
      image: 'assets/images/onboarding4.jpg',
    ),
  ];

  Widget _buildPageContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
            ),
            child: child,
          ),
        );
      },
      child: _pages[_currentPage],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onSkip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: Stack(
        children: [
          // Full screen page view
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                  }
                  return Transform.scale(scale: value, child: child);
                },
                child: _buildPageContent(),
              );
            },
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            pageSnapping: true,
          ),

          // Navigation controls at the top
          // Skip button
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 40.h,
              left: isRTL ? 20.w : null,
              right: isRTL ? null : 20.w,
              child: TextButton(
                onPressed: _onSkip,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(
                    AppColors.primaryColor,
                  ),
                ),
                child: Text(
                  localizations?.skip ?? 'Skip',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Next button
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 40.h,
              right: isRTL ? 20.w : null,
              left: isRTL ? null : 20.w,
              child: GestureDetector(
                onTap: _onNext,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(isRTL ? 3.14159 : 0),
                  child: SvgPicture.asset(
                    'assets/icons/next.svg',
                    width: 30.w,
                    height: 30.h,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom container with dynamic circular cutout
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 281.h,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topRight: isRTL ? Radius.zero : const Radius.circular(150),
                  topLeft: isRTL ? const Radius.circular(150) : Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Back/Finish button section
                  Positioned(
                    left: isRTL ? 20.w : null,
                    right: isRTL ? null : 20.w,
                    bottom: 10.h,
                    child: _currentPage == _pages.length - 1
                        // Finish button (on last page)
                        ? GestureDetector(
                            onTap: _onSkip,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                borderRadius: BorderRadius.circular(30.h),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondaryColor.withOpacity(
                                      0.5,
                                    ),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                localizations?.finish ?? 'Finish',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        // Back button (on other pages)
                        : _currentPage > 0
                        ? GestureDetector(
                            onTap: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                borderRadius: BorderRadius.circular(30.h),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondaryColor.withOpacity(
                                      0.5,
                                    ),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                localizations?.previous ?? 'السابق',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),

                  // Page indicators
                  Positioned(
                    top: 20.h,
                    right: 0,
                    left: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          width: _currentPage == index ? 12.w : 8.w,
                          height: _currentPage == index ? 12.h : 8.h,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.secondaryColor
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content - النص يبدأ من اليمين في العربية
                  Padding(
                    padding: EdgeInsets.only(
                      right: isRTL ? 20.w : 50.w,
                      left: isRTL ? 50.w : 20.w,
                      top: 5.h,
                      bottom: 24.h,
                    ),
                    child: Align(
                      alignment: isRTL
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        _getTranslatedDescription(
                          _pages[_currentPage].description,
                          localizations,
                        ),
                        style: TextStyle(
                          fontSize: 23.sp,
                          color: Colors.grey[600],
                          height: 1.5,
                          fontFamily: AppFonts.reemKufi,
                        ),
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTranslatedDescription(
    String key,
    AppLocalizations? localizations,
  ) {
    switch (key) {
      case 'onboarding_description_1':
        return localizations?.onboardingDescription1 ??
            key.replaceAll('_', ' ');
      case 'onboarding_description_2':
        return localizations?.onboardingDescription2 ??
            key.replaceAll('_', ' ');
      case 'onboarding_description_3':
        return localizations?.onboardingDescription3 ??
            key.replaceAll('_', ' ');
      case 'onboarding_description_4':
        return localizations?.onboardingDescription4 ??
            key.replaceAll('_', ' ');
      default:
        return key.replaceAll('_', ' ');
    }
  }
}

class OnboardingPage extends StatelessWidget {
  final String description;
  final String image;

  const OnboardingPage({
    Key? key,
    required this.description,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        image,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image, size: 100, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
