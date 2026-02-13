import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/presentation/pages/guide_steps_screen.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/pages/subscription_page.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

import '../bloc/hajj_umrah_cubit.dart';

class HajjUmrahHomeScreen extends StatelessWidget {
  const HajjUmrahHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل الحج والعمرة'),
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            final isPremium = state is SubscriptionLoaded && state.subscription.isPremium;

            return Column(
              children: [
                _buildCard(
                  context,
                  title: "مناسك العمرة",
                  icon: Icons.refresh, // Replace with proper icon
                  onTap: () {
                    context.read<HajjUmrahCubit>().loadUmrahGuide();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuideStepsScreen(title: "مناسك العمرة")),
                    );
                  },
                ),
                const SizedBox(height: 16),
                 _buildCard(
                  context,
                  title: "مناسك الحج",
                  icon: Icons.mosque,
                  isLocked: !isPremium,
                  onTap: () {
                    if (!isPremium) {
                      _showPremiumDialog(context);
                      return;
                    }
                    context.read<HajjUmrahCubit>().loadHajjGuide();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuideStepsScreen(title: "مناسك الحج")),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // "My Journey" Section ?
                // For now, progress is integrated into steps list.
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap, bool isLocked = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: Theme.of(context).primaryColor),
                  if (isLocked) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.lock, color: AppColors.goldenColor),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: AppColors.goldenColor),
            const SizedBox(width: 8),
            Text(
              s.premiumFeature,
              style: TextStyle(fontSize: 16, fontFamily: AppFonts.tajawal),
            ),
          ],
        ),
        content: Text(
          s.premiumFeatureDescription,
          style: TextStyle(fontSize: 14, fontFamily: AppFonts.tajawal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blacColor,
            ),
            child: Text(s.upgradeNow),
          ),
        ],
      ),
    );
  }
}
