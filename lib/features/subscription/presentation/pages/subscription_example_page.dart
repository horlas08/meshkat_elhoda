import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import '../../../../core/services/service_locator.dart';
import '../../domain/entities/app_feature.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_state.dart';

class SubscriptionExamplePage extends StatelessWidget {
  const SubscriptionExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<SubscriptionBloc>()..add(LoadSubscriptionEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text("Subscription Feature Test")),
        body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(child: QuranLottieLoading());
            } else if (state is SubscriptionLoaded) {
              final featureManager = state.featureManager;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    "Current Plan: ${state.subscription.type.toUpperCase()}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Example 1: Direct Getter Usage
                  ListTile(
                    title: const Text("Advanced Tafseer"),
                    subtitle: Text(
                      featureManager.canUseAdvancedTafseer
                          ? "Unlocked"
                          : "Locked",
                    ),
                    trailing: Icon(
                      featureManager.canUseAdvancedTafseer
                          ? Icons.check_circle
                          : Icons.lock,
                      color: featureManager.canUseAdvancedTafseer
                          ? Colors.green
                          : Colors.red,
                    ),
                    onTap: () {
                      if (!featureManager.canUseAdvancedTafseer) {
                        _showUpgradeDialog(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Opening Advanced Tafseer..."),
                          ),
                        );
                      }
                    },
                  ),

                  // Example 2: Enum Usage
                  ListTile(
                    title: const Text("Offline Audio"),
                    subtitle: Text(
                      featureManager.isAllowed(AppFeature.offlineAudio)
                          ? "Unlocked"
                          : "Locked",
                    ),
                    trailing: Icon(
                      featureManager.isAllowed(AppFeature.offlineAudio)
                          ? Icons.check_circle
                          : Icons.lock,
                      color: featureManager.isAllowed(AppFeature.offlineAudio)
                          ? Colors.green
                          : Colors.red,
                    ),
                    onTap: () {
                      if (!featureManager.isAllowed(AppFeature.offlineAudio)) {
                        _showUpgradeDialog(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Playing Offline Audio..."),
                          ),
                        );
                      }
                    },
                  ),

                  // Example 3: Free Feature
                  ListTile(
                    title: const Text("Daily AI Limit (Free)"),
                    subtitle: Text(
                      featureManager.canUseFreeAIDailyLimit
                          ? "Unlocked"
                          : "Locked",
                    ),
                    trailing: Icon(
                      featureManager.canUseFreeAIDailyLimit
                          ? Icons.check_circle
                          : Icons.lock,
                      color: Colors.green,
                    ),
                  ),
                ],
              );
            } else if (state is SubscriptionError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Upgrade to Premium"),
        content: const Text(
          "This feature is only available for premium users.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to payment screen
              Navigator.pop(context);
            },
            child: const Text("Upgrade Now"),
          ),
        ],
      ),
    );
  }
}
