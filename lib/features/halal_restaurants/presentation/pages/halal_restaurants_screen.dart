import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/presentation/bloc/halal_restaurants_bloc.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/presentation/bloc/halal_restaurants_event.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/presentation/bloc/halal_restaurants_state.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/presentation/pages/halal_restaurants_map_screen.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/presentation/widgets/restaurant_card.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';

import '../../../../l10n/app_localizations.dart';

class HalalRestaurantsScreen extends StatelessWidget {
  const HalalRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HalalRestaurantsBloc>()
        ..add(const GetNearbyHalalRestaurantsEvent()),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IslamicAppbar(
                  title: AppLocalizations.of(context)?.halalRestaurants ??
                      'مطاعم حلال',
                  fontSize: 18.sp,
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<HalalRestaurantsBloc,
                          HalalRestaurantsState>(
                        builder: (context, state) {
                          return OutlinedButton.icon(
                            onPressed: () {
                              if (state is HalalRestaurantsLoaded &&
                                  state.restaurants.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => HalalRestaurantsMapScreen(
                                      restaurants: state.restaurants,
                                      userLatitude: state.userLatitude,
                                      userLongitude: state.userLongitude,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)
                                              ?.pleaseWaitForMosquesToLoad ?? // Fallback to same msg for now
                                          'الرجاء الانتظار حتى يتم تحميل البيانات',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              side: const BorderSide(
                                color: AppColors.goldenColor,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              foregroundColor: AppColors.goldenColor,
                            ),
                            icon: const Icon(Icons.map_outlined, size: 20),
                            label: Text(
                              AppLocalizations.of(context)?.showOnMap ??
                                  'عرض على الخريطة',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontFamily: AppFonts.tajawal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: BlocBuilder<HalalRestaurantsBloc,
                          HalalRestaurantsState>(
                        builder: (context, state) {
                          final isLoading = state is HalalRestaurantsLoading;
                          return ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => context
                                    .read<HalalRestaurantsBloc>()
                                    .add(const GetNearbyHalalRestaurantsEvent()),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              backgroundColor: AppColors.goldenColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: SizedBox(
                              width: 20,
                              height: 20,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    )
                                  : const Icon(Icons.my_location, size: 20),
                            ),
                            label: Text(
                              isLoading
                                  ? AppLocalizations.of(context)?.updating ??
                                      'جارِ التحديث...'
                                  : AppLocalizations.of(context)
                                          ?.updateLocation ??
                                      'تحديث الموقع',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontFamily: AppFonts.tajawal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: BlocBuilder<HalalRestaurantsBloc,
                      HalalRestaurantsState>(
                    builder: (context, state) {
                      if (state is HalalRestaurantsLoading) {
                        return const QuranLottieLoading();
                      }
                      if (state is HalalRestaurantsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: AppTextStyles.surahName,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      if (state is HalalRestaurantsLoaded) {
                        if (state.restaurants.isEmpty) {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)
                                      ?.noNearbyMosquesInRange ?? // Fallback
                                  'لا توجد مطاعم حلال قريبة',
                              style: AppTextStyles.surahName.copyWith(
                                fontFamily: AppFonts.tajawal,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.restaurants.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final r = state.restaurants[index];
                            return RestaurantCard(
                              restaurant: r,
                              userLat: state.userLatitude,
                              userLng: state.userLongitude,
                            );
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
