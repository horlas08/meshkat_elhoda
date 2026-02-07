import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/widgets/theme_switch.dart';
import 'package:meshkat_elhoda/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/settings_title.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/custom_icon.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class ThemeOption extends StatefulWidget {
  const ThemeOption({super.key});

  @override
  State<ThemeOption> createState() => _ThemeOptionState();
}

class _ThemeOptionState extends State<ThemeOption> {
  final GlobalKey<SettingTitleState> _titleKey = GlobalKey<SettingTitleState>();

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;

        return Column(
          children: [
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                showTrailingIcon: false,
                onExpansionChanged: (expanded) {
                  _titleKey.currentState?.setExpanded(expanded);
                },
                title: SettingTitle(
                  key: _titleKey,
                  title: s.appearanceTitle,
                  iconPath: AppAssets.pin,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        CustomIcon(
                          iconPath: isDark ? AppAssets.moon : AppAssets.sun,
                        ),

                        SizedBox(width: 10.w),

                        Text(
                          isDark ? s.darkMode : s.lightMode,
                          style: AppTextStyles.surahName.copyWith(
                            fontFamily: AppFonts.tajawal,
                            fontSize: 11.sp,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? AppColors.blacColor
                                : AppColors.whiteColor,
                          ),
                        ),

                        const Spacer(),

                        ThemeSwitch(
                          onTap: () {
                            context.read<ThemeCubit>().toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
