import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/features/collective_khatma/presentation/pages/collective_khatma_page.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/pages/subscription_page.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class CollectiveKhatmaPageWithSubscription extends StatefulWidget {
  const CollectiveKhatmaPageWithSubscription({Key? key}) : super(key: key);

  @override
  State<CollectiveKhatmaPageWithSubscription> createState() =>
      _CollectiveKhatmaPageWithSubscriptionState();
}

class _CollectiveKhatmaPageWithSubscriptionState
    extends State<CollectiveKhatmaPageWithSubscription> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // تحميل بيانات الاشتراك
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subscriptionState) {
        // إذا كانت البيانات قيد التحميل
        if (subscriptionState is SubscriptionLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)?.collectiveKhatma ??
                    'الختمة الجماعية',
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // التحقق من حالة الاشتراك
        final isPremium =
            subscriptionState is SubscriptionLoaded &&
            subscriptionState.subscription.isPremium;

        // إذا لم يكن مشتركاً، عرض شاشة القفل
        if (!isPremium) {
          return _buildPremiumRequiredScreen(context);
        }

        // إذا كان مشتركاً، عرض الصفحة العادية
        return const CollectiveKhatmaPage();
      },
    );
  }

  Widget _buildPremiumRequiredScreen(BuildContext context) {
    final s = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s?.collectiveKhatma ?? 'الختمة الجماعية')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: AppColors.goldenColor),
              const SizedBox(height: 24),
              Text(
                s?.premiumFeature ?? 'ميزة مميزة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldenColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.premiumFeatureDescription ??
                    'الختمة الجماعية متاحة للمشتركين المميزين فقط.\nاشترك الآن للاستفادة من هذه الميزة الرائعة!',
                style: TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.star),
                label: Text(s?.upgradeNow ?? 'اشترك الآن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldenColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
