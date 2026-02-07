import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class FavoriteIcon extends StatefulWidget {
  final double size;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const FavoriteIcon({
    super.key,
    this.size = 20,
    this.isFavorite = false,
    this.onFavorite,
  });

  @override
  State<FavoriteIcon> createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<FavoriteIcon> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isFavorite;
  }

  @override
  void didUpdateWidget(FavoriteIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      isSelected = widget.isFavorite;
    }
  }

  void toggleFavorite() {
    // We update local state for immediate feedback,
    // but the parent should also update the isFavorite prop eventually.
    setState(() {
      isSelected = !isSelected;
    });

    if (widget.onFavorite != null) {
      widget.onFavorite!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isSelected ? Icons.star_rounded : Icons.star_rounded,
        color: isSelected ? AppColors.goldenColor : AppColors.greyColor,
        size: widget.size.sp,
      ),
      onPressed: toggleFavorite,
    );
  }
}
