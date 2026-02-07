import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/azkar_model.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar_category.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/screens/zekr_details_view.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/all_azkar_list.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/popular_zekr_item.dart';

import '../../../../l10n/app_localizations.dart';

// ignore: must_be_immutable
class PopularAzkarGrid extends StatelessWidget {
  List<AzkarCategory> popularAzkarList;
  final bool isPremium;
  final List<String> freeAzkar;

  PopularAzkarGrid({
    super.key,
    required this.popularAzkarList,
    required this.isPremium,
    required this.freeAzkar,
  });
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 22.h,
      crossAxisSpacing: 22.w,
      childAspectRatio: 4.4,
      children: List.generate(popularAzkarList.length, (index) {
        final category = popularAzkarList[index];
        final isAccessible = isPremium || freeAzkar.contains(category.title);

        return PopularZekrItem(
          zekrType: category.title,
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

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  // استخدام Bloc منفصل للتفاصيل
                  value: getIt<AzkarBloc>(),
                  child: ZekrDetailsView(
                    zekrId: category.id,
                    categoryTitle: category.title,
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
        );
      }),
    );
  }
}
