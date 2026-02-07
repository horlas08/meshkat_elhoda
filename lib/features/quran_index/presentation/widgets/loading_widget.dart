import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class QuranLottieLoading extends StatelessWidget {
  final String? message;

  const QuranLottieLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/quran_loading.json', // الملف اللي حمّلته
            width: 100.w,
            height: 100.h,
            fit: BoxFit.contain,
          ),
          if (message != null) ...[
            SizedBox(height: 10.h),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}