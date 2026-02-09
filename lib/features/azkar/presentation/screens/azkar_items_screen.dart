import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_state.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/azkar_item_card.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';

import '../../../../l10n/app_localizations.dart';

class AzkarItemsScreen extends StatelessWidget {
  final int categoryId;
  final String categoryTitle;

  const AzkarItemsScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final languageCode = Localizations.localeOf(context).languageCode;
        return getIt<AzkarBloc>()..add(FetchAzkarItems(categoryId, languageCode));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(categoryTitle), centerTitle: true),
        body: BlocBuilder<AzkarBloc, AzkarState>(
          builder: (context, state) {
            if (state is AzkarLoading) {
              return const Center(child: QuranLottieLoading());
            }

            if (state is AzkarError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final languageCode = Localizations.localeOf(context).languageCode;
                        context.read<AzkarBloc>().add(
                          FetchAzkarItems(categoryId, languageCode),
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is AzkarItemsLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return AzkarItemCard(azkar: item);
                },
              );
            }

            return Center(child: Text(AppLocalizations.of(context)!.noData));
          },
        ),
      ),
    );
  }
}
