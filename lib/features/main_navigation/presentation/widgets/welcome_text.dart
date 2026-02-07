import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class WelcomeText extends StatelessWidget {
  final String userName;

  const WelcomeText({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${AppLocalizations.of(context)!.welcome} $userName',
      style: AppTextStyles.surahName.copyWith(
        fontSize: 16.sp,
        fontFamily: AppFonts.tajawal,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
      ),
    );
  }
}
