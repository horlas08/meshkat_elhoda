import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class CustomIcon extends StatelessWidget {
  final String iconPath;
  final Color? color;
  final double? height;
  final double? width;

  const CustomIcon({
    super.key,
    required this.iconPath,
    this.color,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (height ?? 16).h,
      width: (width ?? 16).w,
      child: SvgPicture.asset(
        iconPath,
        fit: BoxFit.contain,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
      ),
    );
  }
}
