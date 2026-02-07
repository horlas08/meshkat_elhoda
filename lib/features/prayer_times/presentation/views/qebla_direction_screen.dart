import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:prayers_times/prayers_times.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:math' as math;

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({Key? key}) : super(key: key);

  @override
  _QiblaScreenState createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  double? _deviceHeading;
  bool _isLoading = true;
  String _errorMessage = '';
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initializeQibla();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeQibla() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // 1. Get Current Location directly from device
      final position = await _determinePosition();

      // 2. Calculate Qibla Direction
      _calculateQiblaDirection(position.latitude, position.longitude);

      // 3. Start Compass Listener
      _startCompassListening();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(AppLocalizations.of(context)!.locationServicesDisabled);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          AppLocalizations.of(context)!.locationPermissionDeniedTitle,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        AppLocalizations.of(context)!.locationPermissionDeniedForeverTitle,
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  void _calculateQiblaDirection(double latitude, double longitude) {
    try {
      Coordinates coordinates = Coordinates(latitude, longitude);
      double direction = Qibla.qibla(coordinates);

      if (mounted) {
        setState(() {
          _qiblaDirection = direction;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(
            context,
          )!.errorCalculatingQiblaDirection;
          _isLoading = false;
        });
      }
    }
  }

  void _startCompassListening() {
    _compassSubscription = FlutterCompass.events?.listen(
      (CompassEvent event) {
        if (mounted) {
          setState(() {
            _deviceHeading = event.heading;

            // If we successfully got a heading, we are no longer loading
            if (_isLoading && _qiblaDirection != null) {
              _isLoading = false;
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.errorAccessingCompass;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: IslamicAppbar(
                title: AppLocalizations.of(context)!.qiblaDirection,
                fontSize: 20.sp,
                onTap: () => Navigator.pop(context),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show loading only if we define "loading" as waiting for initial data.
    if (_isLoading && _qiblaDirection == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const QuranLottieLoading(),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context)!.locatingYourPosition,
              style: TextStyle(
                fontFamily: AppFonts.tajawal,
                fontSize: 16.sp,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_rounded,
                color: Colors.red[400],
                size: 64.sp,
              ),
              SizedBox(height: 20.h),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.tajawal,
                  fontSize: 16.sp,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: _initializeQibla,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldenColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _build3DCompass(),

          SizedBox(height: 48.h),

          if (_qiblaDirection != null)
            Column(
              children: [
                Text(
                  '${_qiblaDirection!.toStringAsFixed(0)}°',
                  style: TextStyle(
                    fontFamily: AppFonts.tajawal,
                    fontSize: 42.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldenColor,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.qiblaDirectionFromNorth,
                  style: TextStyle(
                    fontFamily: AppFonts.tajawal,
                    fontSize: 14.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          SizedBox(height: 24.h),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isAligned() ? 1.0 : 0.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context)!.youAreFacingTheQibla,
                    style: TextStyle(
                      fontFamily: AppFonts.tajawal,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isAligned() {
    if (_deviceHeading == null || _qiblaDirection == null) return false;
    double diff = (_qiblaDirection! - _deviceHeading!) % 360;
    if (diff > 180) diff -= 360;
    return diff.abs() < 5;
  }

  Widget _build3DCompass() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Rotate dial opposite to device heading
    final double rotationAngle = ((_deviceHeading ?? 0) * (math.pi / 180) * -1);
    final double qiblaAngleRad = ((_qiblaDirection ?? 0) * (math.pi / 180));

    // Outer Dial Size
    final double size = 300.w;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          if (isDark)
            BoxShadow(
              color: AppColors.goldenColor.withOpacity(0.05),
              blurRadius: 60,
              spreadRadius: -10,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Compass Dial (Rotates with Device)
          Transform.rotate(
            angle: rotationAngle,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF252525) : Colors.white,
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 4,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cardinal Directions
                  _buildCardinalDirection('N', Alignment.topCenter, Colors.red),
                  _buildCardinalDirection(
                    'S',
                    Alignment.bottomCenter,
                    isDark ? Colors.white : Colors.black,
                  ),
                  _buildCardinalDirection(
                    'E',
                    Alignment.centerRight,
                    isDark ? Colors.white : Colors.black,
                  ),
                  _buildCardinalDirection(
                    'W',
                    Alignment.centerLeft,
                    isDark ? Colors.white : Colors.black,
                  ),

                  // Intermediate ticks
                  ...List.generate(4, (index) {
                    return Transform.rotate(
                      angle: (index * 90 + 45) * math.pi / 180,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.only(top: 20.w),
                          width: 2.w,
                          height: 10.w,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }),

                  // Qibla Indicator on the Dial - الكعبة المشرفة
                  // بديل مبسط للكعبة
                  Transform.rotate(
                    angle: qiblaAngleRad,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 5.h),
                            // الشريط الذهبي
                            Container(
                              width: 40.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: AppColors.goldenColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4.r),
                                  topRight: Radius.circular(4.r),
                                ),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 0.5.w,
                                ),
                              ),
                            ),

                            // جسم الكعبة
                            Container(
                              width: 40.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFF111111),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8.r),
                                  bottomRight: Radius.circular(8.r),
                                ),
                                border: Border.all(
                                  color: const Color(0xFF333333),
                                  width: 1.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Fixed Pointer (Reference at top)
                  Positioned(
                    top: 0,
                    child: Container(
                      height: 24.h,
                      width: 4.w,
                      decoration: BoxDecoration(
                        color: AppColors.goldenColor,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldenColor.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Center Pin
                  Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: AppColors.goldenColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        const BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardinalDirection(
    String label,
    Alignment alignment,
    Color color,
  ) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
