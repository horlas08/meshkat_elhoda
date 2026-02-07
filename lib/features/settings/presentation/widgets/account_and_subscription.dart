import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/settings_title.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/pages/subscription_page.dart';

class AccountAndSubscription extends StatefulWidget {
  const AccountAndSubscription({super.key});

  @override
  State<AccountAndSubscription> createState() => _AccountAndSubscriptionState();
}

class _AccountAndSubscriptionState extends State<AccountAndSubscription> {
  final GlobalKey<SettingTitleState> _titleKey = GlobalKey<SettingTitleState>();

  String _getSubscriptionStatusText(String type) {
    final s = AppLocalizations.of(context)!;
    switch (type) {
      case 'monthly':
        return s.monthlySubscription;
      case 'yearly':
        return s.yearlySubscription;
      case 'premium':
        return s.premiumSubscription;
      case 'free':
      default:
        return s.freeSubscription;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        String statusText = s.freeSubscription;
        bool isPremium = false;
        DateTime? expiryDate;

        if (state is SubscriptionLoaded) {
          statusText = _getSubscriptionStatusText(state.subscription.type);
          isPremium = state.subscription.isPremium;
          expiryDate = state.subscription.expireAt;
        }

        final textColor = Theme.of(context).brightness == Brightness.light
            ? AppColors.blacColor
            : AppColors.whiteColor;

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
                  title: s.accountAndSubscription,
                  iconPath: AppAssets.vip,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '${s.accountStatus}: ',
                              style: AppTextStyles.surahName.copyWith(
                                fontFamily: AppFonts.tajawal,
                                color: textColor,
                              ),
                            ),
                            Text(
                              statusText,
                              style: AppTextStyles.surahName.copyWith(
                                fontFamily: AppFonts.tajawal,
                                color: isPremium
                                    ? AppColors.goldenColor
                                    : textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (expiryDate != null) ...[
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                '${s.expiresOn}: ',
                                style: AppTextStyles.surahName.copyWith(
                                  fontFamily: AppFonts.tajawal,
                                  color: textColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                              Text(
                                _formatDate(expiryDate),
                                style: AppTextStyles.surahName.copyWith(
                                  fontFamily: AppFonts.tajawal,
                                  color: textColor.withOpacity(0.8),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isPremium ? s.manageSubscription : s.upgradeAccount,
                          style: AppTextStyles.surahName.copyWith(
                            fontFamily: AppFonts.tajawal,
                            color: textColor,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SubscriptionPage(),
                              ),
                            );
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 4.h,
                              horizontal: 12.w,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldenColor,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              isPremium ? s.manage : s.subscribe,
                              style: AppTextStyles.surahName.copyWith(
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFonts.tajawal,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppColors.whiteColor
                                    : AppColors.blacColor,
                              ),
                            ),
                          ),
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
