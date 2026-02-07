import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class HadithNavigation extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool hasNext;
  final bool hasPrevious;

  const HadithNavigation({
    Key? key,
    required this.onNext,
    required this.onPrevious,
    required this.hasNext,
    required this.hasPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Next Button (on the right in RTL)
          _buildNavigationButton(
            text: AppLocalizations.of(context)!.next,
            icon: Icons.arrow_forward_ios,
            isEnabled: hasNext,
            onPressed: onNext,
          ),

          // Previous Button (on the left in RTL)
          _buildNavigationButton(
            text: AppLocalizations.of(context)!.previous,
            icon: Icons.arrow_back_ios,
            isEnabled: hasPrevious,
            onPressed: onPrevious,
            isPrevious: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required String text,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
    bool isPrevious = false,
  }) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? AppColors.goldenColor : Colors.grey[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isPrevious) ...[SizedBox(width: 4.w)],
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.white : Colors.grey[600],
              fontFamily: 'Tajawal',
            ),
          ),
          if (isPrevious) ...[SizedBox(width: 4.w)],
          Icon(
            icon,
            size: 14.sp,
            color: isEnabled ? Colors.white : Colors.grey[600],
          ),
        ],
      ),
    );
  }
}
