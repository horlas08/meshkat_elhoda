import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar_category.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/screens/zekr_details_view.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/zekr_category.dart';

import '../../../../l10n/app_localizations.dart';

class AllAzkarList extends StatelessWidget {
  final List<AzkarCategory> categories;
  final bool isPremium;
  final List<String> freeAzkar;
  final Function() onTap;

  const AllAzkarList({
    super.key,
    required this.categories,
    required this.isPremium,
    required this.freeAzkar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final zekr = categories[index];
        final isAccessible = isPremium || freeAzkar.contains(zekr.title);

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ZkerCategory(
            zekrName: zekr.title,
            isAccessible: isAccessible,
            onTap: () async {
              // Check access before navigation
              if (!isAccessible) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.premiumOnlyFeature),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Navigate to details
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    // استخدام Bloc منفصل للتفاصيل
                    value: getIt<AzkarBloc>(),
                    child: ZekrDetailsView(
                      zekrId: zekr.id,
                      categoryTitle: zekr.title,
                    ),
                  ),
                ),
              );

              // When returning from details, reload the categories
              if (context.mounted) {
                // Add a small delay to ensure smooth transition
                await Future.delayed(const Duration(milliseconds: 300));
                if (context.mounted) {
                  // Use the full event class name with the event file import
                  context.read<AzkarBloc>().add(FetchAzkarCategories());
                }
              }
            },
          ),
        );
      },
    );
  }
}
