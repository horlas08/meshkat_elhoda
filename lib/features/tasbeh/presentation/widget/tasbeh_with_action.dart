import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/tasbeh_action_button.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/tasbeh_circle.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class SebhaWithActions extends StatefulWidget {
  final int counter;
  final Function(int) onCounterChanged;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final bool isSaving;

  const SebhaWithActions({
    super.key,
    required this.counter,
    required this.onCounterChanged,
    required this.onReset,
    required this.onSave,
    required this.isSaving,
  });

  @override
  State<SebhaWithActions> createState() => _SebhaWithActionsState();
}

class _SebhaWithActionsState extends State<SebhaWithActions> {
  int beadCount = 18;
  double turns = 0;

  @override
  void initState() {
    super.initState();
    // حساب الدورات بناءً على العداد الحالي
    turns = (widget.counter % beadCount) / beadCount;
  }

  void onTap() {
    final newCounter = widget.counter + 1;
    widget.onCounterChanged(newCounter);
    setState(() {
      turns += 1 / beadCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Column(
      children: [
        InkWell(
          onTap: widget.isSaving ? null : onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: TasbehCircle(
            turns: turns,
            circleSize: 200,
            beadCount: beadCount,
            counter: widget.counter,
          ),
        ),

        SizedBox(height: 88.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TasbeehActionButton(
              iconPath: AppAssets.reset,
              onTap: widget.isSaving
                  ? null
                  : () {
                      widget.onReset();
                      setState(() {
                        turns = 0;
                      });
                    },
              backgroundColor: AppColors.greyColor,
              text: s.reset,
            ),
            TasbeehActionButton(
              text: widget.isSaving ? s.saving : s.save,
              iconPath: AppAssets.save,
              onTap: widget.isSaving ? null : widget.onSave,
              backgroundColor: AppColors.buttonColor,
            ),
          ],
        ),
      ],
    );
  }
}
