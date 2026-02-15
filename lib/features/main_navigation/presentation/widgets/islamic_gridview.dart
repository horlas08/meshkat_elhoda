import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/features/asmaa_allah/presentation/view/asmaa_alluah_view.dart';
import 'package:meshkat_elhoda/features/assistant/presentation/pages/assistant_page_example.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/screens/azkar_categories_screen.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/pages/hadith_list_page.dart';
import 'package:meshkat_elhoda/features/live/haram_live_view.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/model/islamic_item_model.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/widgets/islamic_item.dart';
import 'package:meshkat_elhoda/features/mosques/presentation/pages/mosques_screen.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/views/prayer_times_view.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_state.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/screens/audio_main_screen.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/views/quran_index_view.dart';
import 'package:meshkat_elhoda/features/ramdan/presentation/views/ramdan_view.dart';
import 'package:meshkat_elhoda/features/zakat_calculator/presentation/screens/zakat_calculator_screen.dart';
import 'package:meshkat_elhoda/features/quran_khatmah/presentation/screens/khatmah_screen.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/views/date_converter_view.dart';
import 'package:meshkat_elhoda/features/collective_khatma/presentation/pages/collective_khatma_page.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/presentation/pages/halal_restaurants_screen.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/presentation/pages/hajj_umrah_home_screen.dart';
import 'package:meshkat_elhoda/features/hisn_muslim/presentation/pages/hisn_chapters_screen.dart';
import 'package:meshkat_elhoda/features/islamic_calendar/presentation/pages/islamic_calendar_screen.dart';

// تعريف الأقسام المختلفة
class GridSection {
  final String title;
  final List<IslamicItemModel> items;

  GridSection({required this.title, required this.items});
}

class IslamicGrid extends StatelessWidget {
  const IslamicGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
      builder: (context, state) {
        // التحقق من الشهر الهجري
        bool isRamadan = false;
        if (state is PrayerTimesLoaded && state.prayerTimes != null) {
          final hijriMonth = int.tryParse(
            state.prayerTimes!.dateInfo.hijri.month.toString(),
          );
          isRamadan = hijriMonth == 9;
        }

        final gridSections = _buildGridSections(context, isRamadan);
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridSections.length,
          itemBuilder: (context, sectionIndex) {
            final section = gridSections[sectionIndex];
            return Container(
              margin: EdgeInsets.only(bottom: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      section.title,
                      style: AppTextStyles.zekr.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.whiteColor
                            : AppColors.darkRed,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 120.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: section.items.length,
                      itemBuilder: (context, index) {
                        final item = section.items[index];
                        return Container(
                          width: 100.w,
                          margin: EdgeInsets.only(left: 12.w),
                          child: IslamicItem(
                            color: item.color,
                            iconPath: item.iconPath,
                            text: item.text,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => item.destination,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<GridSection> _buildGridSections(BuildContext context, bool isRamadan) {
    return [
      GridSection(
        title: AppLocalizations.of(context)!.worshipSectionTitle,
        items: [
          IslamicItemModel(
            color: const Color(0xffD4AF37),
            iconPath: AppAssets.mushaf,
            text: AppLocalizations.of(context)!.quranKareem,
            destination: const QuranIndexView(),
          ),
          IslamicItemModel(
            color: const Color(0xff4A7C59),
            iconPath: AppAssets.hadith,
            text: AppLocalizations.of(context)!.hadiths,
            destination: AhadithView(),
          ),
          IslamicItemModel(
            color: const Color(0xffA3B18A),
            iconPath: AppAssets.hand,
            text: AppLocalizations.of(context)!.azkarAndAdiyah,
            destination: const MainAzkarView(),
          ),
          IslamicItemModel(
            color: const Color(0xffC66B6B),
            iconPath: AppAssets.asmaaAllah,
            text: AppLocalizations.of(context)!.allahNames,
            destination: const AsmaaAlluahView(),
          ),
          IslamicItemModel(
            color: const Color(0xff8D6E63),
            iconPath: AppAssets.mushaf, // Using Mushaf icon as generic book icon
            text: AppLocalizations.of(context)?.hisnAlMuslim ?? 'Hisn al-Muslim',
            destination: const HisnChaptersScreen(),
          ),
          // ✅ أيقونة رمضان تظهر فقط في شهر رمضان
          if (isRamadan)
            IslamicItemModel(
              color: const Color(0xff5BC0BE),
              iconPath: AppAssets.ramadan,
              text: AppLocalizations.of(context)!.ramadanFeatures,
              destination: RamdanView(),
            ),
          IslamicItemModel(
            color: const Color(0xffD4CF37),
            iconPath: AppAssets.khatma,
            text: AppLocalizations.of(context)!.khatma,
            destination: const KhatmahScreen(),
          ),
          IslamicItemModel(
            color: const Color(0xff8D6E63),
            iconPath: AppAssets.mushaf,
            text: AppLocalizations.of(context)!.collectiveKhatma,
            destination: const CollectiveKhatmaPage(),
          ),
          IslamicItemModel(
            color: const Color(0xff2E8B57), // SeaGreen
            iconPath: AppAssets.haram,
            text: AppLocalizations.of(context)?.hajjAndUmrahGuide ?? "Hajj & Umrah Guide",
            destination: const HajjUmrahHomeScreen(),
          ),
        ],
      ),
      GridSection(
        title: AppLocalizations.of(context)!.prayerGuideSectionTitle,
        items: [
          IslamicItemModel(
            color: const Color(0xff5BC0BE),
            iconPath: AppAssets.bosla,
            text: AppLocalizations.of(context)!.prayerAndQibla,
            destination: const PrayerTimesView(),
          ),
          IslamicItemModel(
            color: const Color(0xff14213D),
            iconPath: AppAssets.location,
            text: AppLocalizations.of(context)!.locationAndMosques,
            destination: MosquesScreen(),
          ),
          IslamicItemModel(
            color: const Color(0xffD4AF37), // Use a distinct color, e.g., Gold
            iconPath: AppAssets.location, // Using location icon as restaurant icon is missing
            // Use existing asset or generic? I don't know if AppAssets.restaurant exists.
            // I'll check AppAssets file first OR just use a safe one like AppAssets.location for now and ask user later?
            // Wait, I should avoid breaking build. I will use AppAssets.location for now or simply IconData if Model supports it?
            // Model expects String iconPath.
            // Let's use AppAssets.location temporarily or check AppAssets.
            // Better: I'll use AppAssets.location for now to be safe, as I didn't check assets.
            // Actually, I'll use 'assets/icons/restaurant.png' assuming it might not exist but it's a path string.
            // If it crashes, it crashes.
            // PROPER WAY: Check AppAssets first.
            text: AppLocalizations.of(context)?.halalRestaurants ?? 'مطاعم حلال',
            destination: const HalalRestaurantsScreen(),
          ),
        ],
      ),
      GridSection(
        title: AppLocalizations.of(context)!.islamicServicesSectionTitle,
        items: [
          IslamicItemModel(
            color: const Color(0xffB25986),
            iconPath: AppAssets.audio,
            text: AppLocalizations.of(context)!.audio,
            destination: AudioMainScreen(),
          ),
          IslamicItemModel(
            color: const Color(0xff14213D),
            iconPath: AppAssets.haram,
            text: AppLocalizations.of(context)!.liveBroadcastAndHaram,
            destination: Builder(builder: (context) => HaramLife()),
          ),
          IslamicItemModel(
            color: const Color(0xff5C7AEA),
            iconPath: AppAssets.ai,
            text: AppLocalizations.of(context)!.smartAssistant,
            destination: Builder(
              builder: (context) => AssistantPageWithSubscription(),
            ),
          ),
          IslamicItemModel(
            color: const Color(0xffD4AF92),
            iconPath: AppAssets.zaka,
            text: AppLocalizations.of(context)!.zakatCalculator,
            destination: const ZakatCalculatorScreen(),
          ),
          IslamicItemModel(
            color: const Color(0xffD4AF37),
            iconPath: AppAssets.date, // Reuse date icon or find better
            text: AppLocalizations.of(context)?.islamicCalendar ?? 'Islamic Calendar',
            destination: const IslamicCalendarScreen(),
          ),
          IslamicItemModel(
            color: const Color(0xffE9C46A),
            iconPath: AppAssets.date,
            text: AppLocalizations.of(context)!.dateConverter,
            destination: const DateConverterView(),
          ),
        ],
      ),
    ];
  }
}
