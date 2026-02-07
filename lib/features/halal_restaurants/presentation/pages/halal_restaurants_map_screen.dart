import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/domain/entities/restaurant.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../l10n/app_localizations.dart';

class HalalRestaurantsMapScreen extends StatefulWidget {
  final List<Restaurant> restaurants;
  final double userLatitude;
  final double userLongitude;

  const HalalRestaurantsMapScreen({
    super.key,
    required this.restaurants,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  State<HalalRestaurantsMapScreen> createState() =>
      _HalalRestaurantsMapScreenState();
}

class _HalalRestaurantsMapScreenState extends State<HalalRestaurantsMapScreen> {
  GoogleMapController? _mapController;
  Restaurant? _selectedRestaurant;
  final Set<Polyline> _polylines = {};

  // TODO: Move API keys to a secure/shared location (e.g., environment variables)
  static String get _apiKey {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'AIzaSyBvhRpDGH8cx71K9CUkF5GUygIzJNJWCCs'; // iOS key
    }
    return 'AIzaSyDmgxQIRDwTzrU6ph702YXadBPLSzv2pnc'; // Android key
  }

  Future<void> _drawRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving&key=$_apiKey',
      );
      final res = await http.get(uri);
      if (res.statusCode != 200)
        throw Exception('Directions status ${res.statusCode}');
      final decoded = json.decode(res.body) as Map<String, dynamic>;
      if (decoded['status'] != 'OK') {
        final status = decoded['status'] as String? ?? 'UNKNOWN';
        final errorMessage = decoded['error_message'] as String? ?? '';
        throw Exception('Directions API: $status - $errorMessage');
      }
      final routes = decoded['routes'] as List<dynamic>;
      if (routes.isEmpty) return;
      final overview =
          routes.first['overview_polyline'] as Map<String, dynamic>;
      final points = overview['points'] as String?;
      if (points == null) return;

      final polylinePoints = PolylinePoints().decodePolyline(points);
      final polylineCoords = polylinePoints
          .map((pt) => LatLng(pt.latitude, pt.longitude))
          .toList();

      setState(() {
        _polylines
          ..clear()
          ..add(
            Polyline(
              polylineId: const PolylineId('route'),
              width: 5,
              color: Colors.blueAccent,
              points: polylineCoords,
            ),
          );
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(_boundsFromLatLngList(polylineCoords), 60),
      );
    } catch (_) {}
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0 = list.first.latitude;
    double x1 = list.first.latitude;
    double y0 = list.first.longitude;
    double y1 = list.first.longitude;

    for (final latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }

    return LatLngBounds(southwest: LatLng(x0, y0), northeast: LatLng(x1, y1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: IslamicAppbar(
                  title: AppLocalizations.of(context)?.map ?? 'الخريطة',
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final user = LatLng(
                      widget.userLatitude,
                      widget.userLongitude,
                    );

                    final markers = <Marker>{
                      Marker(
                        markerId: const MarkerId('me'),
                        position: user,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,
                        ),
                        infoWindow: InfoWindow(
                          title:
                              AppLocalizations.of(context)?.myCurrentLocation ??
                                  'موقعي الحالي',
                        ),
                      ),
                    };

                    for (final r in widget.restaurants) {
                      markers.add(
                        Marker(
                          markerId: MarkerId(r.id),
                          position: LatLng(r.latitude, r.longitude),
                          infoWindow: InfoWindow(
                            title: r.name,
                            snippet: r.address,
                            onTap: () async {
                              setState(() => _selectedRestaurant = r);
                            },
                          ),
                          onTap: () => setState(() => _selectedRestaurant = r),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: user,
                            zoom: 14,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: false,
                          markers: markers,
                          polylines: _polylines,
                          onMapCreated: (c) => _mapController = c,
                        ),
                        if (_selectedRestaurant != null)
                          Positioned(
                            left: 12.w,
                            right: 12.w,
                            bottom: 12.h,
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedRestaurant!.name,
                                      style: AppTextStyles.surahName.copyWith(
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      _selectedRestaurant!.address,
                                      style: AppTextStyles.topHeadline.copyWith(
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final origin = LatLng(
                                              widget.userLatitude,
                                              widget.userLongitude,
                                            );
                                            final dest = LatLng(
                                              _selectedRestaurant!.latitude,
                                              _selectedRestaurant!.longitude,
                                            );
                                            await _drawRoute(
                                              origin: origin,
                                              destination: dest,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.goldenColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(Icons.alt_route),
                                          label: Text(
                                            AppLocalizations.of(
                                                  context,
                                                )?.directions ??
                                                'الاتجاهات',
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        OutlinedButton.icon(
                                          onPressed: () async {
                                            final url =
                                                'https://www.google.com/maps/dir/?api=1&destination='
                                                '${_selectedRestaurant!.latitude},${_selectedRestaurant!.longitude}';
                                            if (await canLaunchUrlString(url)) {
                                              await launchUrlString(
                                                url,
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.map_outlined),
                                          label: Text(
                                            AppLocalizations.of(
                                                  context,
                                                )?.openInMaps ??
                                                'افتح في الخرائط',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
