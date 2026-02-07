import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar_category.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/azkar_category_card.dart';

class AzkarGrid extends StatelessWidget {
  final List<AzkarCategory> categories;
  final Function(AzkarCategory) onCategoryTap;

  const AzkarGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return AzkarCategoryCard(
          category: category,
          onTap: () => onCategoryTap(category),
        );
      },
    );
  }
}
