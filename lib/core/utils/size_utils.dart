import 'package:flutter/material.dart';

const num FIGMA_DESIGN_WIDTH = 375;
const num FIGMA_DESIGN_HEIGHT = 812;

enum DeviceType { mobile, tablet, desktop }

typedef ResponsiveBuild =
    Widget Function(
      BuildContext context,
      Orientation orientation,
      DeviceType deviceType,
    );

class Sizer extends StatelessWidget {
  const Sizer({super.key, required this.builder});

  final ResponsiveBuild builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeUtils.init(constraints, orientation);
            return builder(context, orientation, SizeUtils.deviceType);
          },
        );
      },
    );
  }
}

class SizeUtils {
  static late BoxConstraints boxConstraints;
  static late Orientation orientation;
  static late double width;
  static late double height;
  static late DeviceType deviceType;

  static void init(BoxConstraints constraints, Orientation ori) {
    boxConstraints = constraints;
    orientation = ori;

    if (orientation == Orientation.portrait) {
      width = constraints.maxWidth;
      height = constraints.maxHeight;
    } else {
      width = constraints.maxHeight;
      height = constraints.maxWidth;
    }

    if (width >= 950) {
      deviceType = DeviceType.desktop;
    } else if (width >= 600) {
      deviceType = DeviceType.tablet;
    } else {
      deviceType = DeviceType.mobile;
    }
  }
}

/// Extensions for scaling
extension SizeExtension on num {
  /// Relative to width
  double get w => (this * SizeUtils.width) / FIGMA_DESIGN_WIDTH;

  /// Relative to height
  double get h => (this * SizeUtils.height) / FIGMA_DESIGN_HEIGHT;

  /// Font scaling
  double get sp => (this * SizeUtils.width) / FIGMA_DESIGN_WIDTH;

  /// Width percent
  double get wp => (this / 100) * SizeUtils.width;

  /// Height percent
  double get hp => (this / 100) * SizeUtils.height;

  /// Border radius (same as width scaling)
  double get r => (this * SizeUtils.width) / FIGMA_DESIGN_WIDTH;
}
