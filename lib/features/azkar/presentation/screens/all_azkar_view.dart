import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/custom_search_field.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar_category.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_state.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/screens/favourit_azkar_view.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/all_azkar_list.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';

import '../../../../l10n/app_localizations.dart';

class AllAzkarView extends StatefulWidget {
  const AllAzkarView({super.key});

  @override
  State<AllAzkarView> createState() => _AllAzkarViewState();
}

class _AllAzkarViewState extends State<AllAzkarView> {
  // الأذكار المتاحة للنسخة المجانية
  static const List<String> freeAzkar = [
    'أذكار الصباح والمساء',
    'أذكار النوم',
    'الأذكار بعد السلام من الصلاة',
  ];

  @override
  void initState() {
    super.initState();
    // Load subscription
    context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());
    // Ensure categories are loaded
    final languageCode = Localizations.localeOf(context).languageCode;
    context.read<AzkarBloc>().add(FetchAzkarCategories(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AzkarBloc, AzkarState>(
        builder: (context, state) {
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IslamicAppbar(
                      title: AppLocalizations.of(context)!.allAzkar,
                      fontSize: 20.sp,
                      onTap: () => Navigator.pop(context),
                    ),

                    SizedBox(height: 24.h),

                    CustomSearchField(
                      onFavourit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavouritAzkarView(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24.h),

                    if (state is AzkarCategoriesLoaded)
                      BlocBuilder<SubscriptionBloc, SubscriptionState>(
                        builder: (context, subscriptionState) {
                          final isPremium =
                              subscriptionState is SubscriptionLoaded &&
                              subscriptionState.subscription.isPremium;

                          // Sort categories: free azkar first
                          final sortedCategories = List<AzkarCategory>.from(
                            state.categories,
                          );
                          sortedCategories.sort((a, b) {
                            final aIsFree = freeAzkar.contains(a.title);
                            final bIsFree = freeAzkar.contains(b.title);

                            if (aIsFree && !bIsFree) return -1;
                            if (!aIsFree && bIsFree) return 1;
                            return 0;
                          });

                          return AllAzkarList(
                            categories: sortedCategories,
                            isPremium: isPremium,
                            freeAzkar: freeAzkar,
                            onTap: () {},
                          );
                        },
                      ),
                    if (state is AzkarLoading)
                      Center(child: QuranLottieLoading()),
                    if (state is AzkarError)
                      Center(child: Text(AppLocalizations.of(context)!.errorLoadingAzkar)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
