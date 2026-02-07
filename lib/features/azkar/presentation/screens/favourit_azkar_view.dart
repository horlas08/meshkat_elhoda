import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/custom_search_field.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/favourit_zekr_item.dart';

import '../../../../l10n/app_localizations.dart';

class FavouritAzkarView extends StatelessWidget {
  const FavouritAzkarView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IslamicAppbar(
                  title: AppLocalizations.of(context)!.favoriteAzkar,
                  fontSize: 20.sp,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                SizedBox(height: 45.h),
                CustomSearchField(
                  //width: 280.w,
                  //showFavouriteIcon: false,
                  // controller: ,
                ),
                SizedBox(height: 45.h),

                FavoritZekrItem(
                  onFavourit: () {},
                  zekrText: AppLocalizations.of(context)!.favoriteAzkar,
                  repeat: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
