import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/features/asmaa_allah/presentation/data/asmaa_alluah_data.dart';
import 'package:meshkat_elhoda/features/asmaa_allah/presentation/widgets/asmaa_alluah_grid.dart';

class AsmaaAlluahView extends StatefulWidget {
  const AsmaaAlluahView({super.key});

  @override
  State<AsmaaAlluahView> createState() => _AsmaaAlluahViewState();
}

class _AsmaaAlluahViewState extends State<AsmaaAlluahView> {
  int currentPage = 0;
  final PageController pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final List<String> currentAsmaaList = getAsmaaAllahList(languageCode);
    final List<List<String>> pages = currentAsmaaList.slices(40).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: IslamicAppbar(
                title: 'أسماء الله الحسنى',
                fontSize: 20.sp,
                onTap: () => Navigator.pop(context),
              ),
            ),

            // Main Content
            Expanded(
              child: Stack(
                children: [
                  // Background Frame - Full Screen
                  Positioned.fill(
                    child: Image.asset(
                      AppAssets.asmaaAlluahFrame,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                  // Content
                  Positioned.fill(
                    child: Column(
                      children: [
                        // Ayah Text with minimal top padding
                        Padding(
                          padding: EdgeInsets.only(top: 50.h, bottom: 4.h),
                          child: Text(
                            'وَلِلَّهِ الأَسْمَاءُ الْحُسْنَى فَادْعُوهُ بِهَا',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppFonts.reemKufi,
                              color: AppColors.goldenColor,
                              height: 1.5,
                            ),
                          ),
                        ),

                        // Grid View Container - takes remaining space
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 25.w,
                              vertical: 40.h,
                            ),
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: pages.length,
                              onPageChanged: (index) =>
                                  setState(() => currentPage = index),
                              itemBuilder: (context, pageIndex) =>
                                  AsmaaAlluahGrid(names: pages[pageIndex]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Navigation Buttons
                  if (currentPage < pages.length - 1)
                    PositionedDirectional(
                      end: 40.w,
                      bottom: screenSize.height * 0.08,
                      child: IconButton(
                        icon: SizedBox(
                          width: 40.w,
                          height: 40.w,
                          child: SvgPicture.asset(
                            AppAssets.playarrow,
                            fit: BoxFit.contain,
                          ),
                        ),
                        onPressed: () {
                          pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                      ),
                    ),

                  if (currentPage > 0)
                    PositionedDirectional(
                      start: 40.w,
                      bottom: screenSize.height * 0.08,
                      child: IconButton(
                        icon: SizedBox(
                          width: 40.w,
                          height: 40.w,
                          child: SvgPicture.asset(
                            AppAssets.playback,
                            fit: BoxFit.contain,
                          ),
                        ),
                        onPressed: () {
                          pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
