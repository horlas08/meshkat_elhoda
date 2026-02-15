import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meshkat_elhoda/features/location/domain/usecases/get_current_location.dart'
    as usecases;
import 'package:meshkat_elhoda/features/location/domain/usecases/get_location_from_city_country.dart';
import 'package:meshkat_elhoda/features/location/domain/usecases/get_stored_location.dart';
import 'package:meshkat_elhoda/features/location/domain/usecases/request_location_permission.dart'
    as usecases;
import 'package:meshkat_elhoda/features/location/domain/usecases/save_location.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_event.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_state.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:meshkat_elhoda/core/services/location_refresh_service.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meshkat_elhoda/features/location/data/models/location_model.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final usecases.RequestLocationPermission requestLocationPermission;
  final usecases.GetCurrentLocation getCurrentLocation;
  final GetLocationFromCityCountry getLocationFromCityCountry;
  final GetStoredLocation getStoredLocation;
  final SaveLocation saveLocation;
  final LocationRefreshService locationRefreshService;

  LocationBloc({
    required this.requestLocationPermission,
    required this.getCurrentLocation,
    required this.getLocationFromCityCountry,
    required this.getStoredLocation,
    required this.saveLocation,
    required this.locationRefreshService,
  }) : super(LocationInitial()) {
    on<LoadStoredLocation>(_onLoadStoredLocation);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<SetManualLocation>(_onSetManualLocation);
    on<UpdateLocation>(_onUpdateLocation);
    on<ClearLocation>(_onClearLocation);
    on<RefreshLocationIfNeeded>(_onRefreshLocationIfNeeded);
    on<StartLocationUpdates>(_onStartLocationUpdates);
    on<StopLocationUpdates>(_onStopLocationUpdates);
  }

  Future<void> _onLoadStoredLocation(
    LoadStoredLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final result = await getStoredLocation();

    result.fold(
      (failure) {
        // No stored location, try to refresh/get location
        emit(LocationInitial());
        add(const RefreshLocationIfNeeded(forceRefresh: false));
      },
      (location) {
        if (location != null) {
          emit(LocationGranted(location: location));
          // Check if we need to auto-refresh based on settings
          add(const RefreshLocationIfNeeded(forceRefresh: false));
        } else {
          emit(LocationInitial());
          add(const RefreshLocationIfNeeded(forceRefresh: false));
        }
      },
    );
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermissionEvent event,
    Emitter<LocationState> emit,
  ) async {
    // Only show loading if we are NOT already showing a valid location or if it's the initial load
    // This prevents flickering if we are just refreshing in background
    if (state is! LocationGranted) {
      emit(LocationLoading());
    }

    final result = await requestLocationPermission();

    result.fold(
      (failure) {
        emit(LocationError(message: failure.message));
      },
      (status) {
        if (status.isGranted) {
          // Permission granted, now get location
          add(GetCurrentLocationEvent());
        } else if (status.isDenied || status.isPermanentlyDenied) {
          // Only emit denied if we don't have a valid location yet
          // or if the user explicitly requested it?
          // For auto-refresh, if denied, we just stay with what we have if possible
          if (state is! LocationGranted) {
            emit(const LocationDenied());
          }
        } else {
          if (state is! LocationGranted) {
            emit(
              const LocationError(
                message: 'Location permission status unknown',
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    // Only loading indicator if strictly needed
    if (state is! LocationGranted) {
      emit(LocationLoading());
    }

    final result = await getCurrentLocation();

    await result.fold(
      (failure) async {
        // Keep old location if refresh fails
        if (state is! LocationGranted) {
          emit(LocationError(message: failure.message));
        } else {
          log('⚠️ Failed to refresh location: ${failure.message}');
        }
      },
      (location) async {
        LocationEntity finalLocation = location;

        // 1. محاولة الحفاظ على المدينة والدولة من الحالة السابقة إذا كانت الجديدة فارغة
        if ((finalLocation.city == null || finalLocation.country == null) &&
            state is LocationGranted) {
          final oldLocation = (state as LocationGranted).location;
          if (oldLocation.latitude != null &&
              oldLocation.longitude != null &&
              finalLocation.latitude != null &&
              finalLocation.longitude != null) {
            try {
              final distance = Geolocator.distanceBetween(
                finalLocation.latitude!,
                finalLocation.longitude!,
                oldLocation.latitude!,
                oldLocation.longitude!,
              );

              // إذا كانت المسافة أقل من 2 كم، نستخدم البيانات القديمة
              if (distance < 2000) {
                log(
                  '📍 Using cached city/country due to proximity ($distance m)',
                );
                finalLocation = LocationModel.fromEntity(finalLocation)
                    .copyWith(
                      city: oldLocation.city,
                      country: oldLocation.country,
                    );
              }
            } catch (e) {
              log('❌ Error calculating distance: $e');
            }
          }
        }

        // 2. إذا ما زالت البيانات فارغة، نحاول جلبها من Firebase
        if (finalLocation.city == null || finalLocation.country == null) {
          final firebaseLocation = await _getLocationFromFirebase();
          if (firebaseLocation != null) {
            if (finalLocation.latitude != null &&
                finalLocation.longitude != null &&
                firebaseLocation.latitude != null &&
                firebaseLocation.longitude != null) {
              try {
                final distance = Geolocator.distanceBetween(
                  finalLocation.latitude!,
                  finalLocation.longitude!,
                  firebaseLocation.latitude!,
                  firebaseLocation.longitude!,
                );

                // إذا كانت المسافة أقل من 10 كم، نستخدم بيانات Firebase
                if (distance < 10000) {
                  log(
                    '📍 Using Firebase city/country due to proximity ($distance m)',
                  );
                  finalLocation = LocationModel.fromEntity(finalLocation)
                      .copyWith(
                        city: firebaseLocation.city,
                        country: firebaseLocation.country,
                      );
                }
              } catch (e) {
                log('❌ Error calculating distance with Firebase location: $e');
              }
            }
          }
        }

        // حفظ الموقع الجديد في LocationRefreshService
        if (finalLocation.latitude != null && finalLocation.longitude != null) {
          await locationRefreshService.saveCurrentLocation(
            finalLocation.latitude!,
            finalLocation.longitude!,
          );

          // تحديث الموقع في Firebase
          await _updateLocationInFirebase(finalLocation);
        }
        emit(LocationGranted(location: finalLocation));
      },
    );
  }

  /// جلب الموقع المخزن في Firebase
  Future<LocationEntity?> _getLocationFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists &&
          doc.data() != null &&
          doc.data()!.containsKey('location')) {
        final data = doc.data()!['location'] as Map<String, dynamic>;
        return LocationModel.fromJson(data);
      }
    } catch (e) {
      log('❌ Error fetching location from Firebase: $e');
    }
    return null;
  }

  /// تحديث الموقع في Firebase
  Future<void> _updateLocationInFirebase(LocationEntity location) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        log('⚠️ No user logged in - skipping Firebase update');
        return;
      }

      final updates = <String, dynamic>{
        'location.latitude': location.latitude,
        'location.longitude': location.longitude,
        'location.timestamp': location.timestamp.toIso8601String(),
        'location.timezone': location.timezone,
        'location.method': location.method == LocationMethod.gps
            ? 'gps'
            : 'manual',
      };

      if (location.city != null) {
        updates['location.city'] = location.city;
      }
      if (location.country != null) {
        updates['location.country'] = location.country;
      }

      // نستخدم update بدلاً من set لضمان عدم مسح البيانات الأخرى
      // ولكن يجب التأكد من وجود المستند أولاً، أو استخدام set مع merge للحقول المتداخلة
      // الأفضل هنا هو set مع merge ولكن بصيغة map كاملة إذا كنا نريد إنشاء المستند
      // ولكن بما أننا نريد تحديث جزئي للحقول المتداخلة، فالأفضل هو update
      // ولكن update تفشل إذا المستند غير موجود.

      // الحل الأضمن: قراءة المستند أولاً أو استخدام set مع merge للحقول العلوية
      // ولكن set مع merge تستبدل الـ map بالكامل.

      // سنستخدم set مع merge ولكن سنقوم بدمج البيانات القديمة يدوياً إذا لزم الأمر
      // أو الأسهل: استخدام update والتعامل مع خطأ عدم الوجود
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(updates);
      } catch (e) {
        // إذا فشل التحديث (مثلاً المستند غير موجود)، نستخدم set
        final locationData = {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'city': location.city ?? '',
          'country': location.country ?? '',
          'method': location.method == LocationMethod.gps ? 'gps' : 'manual',
          'timezone': location.timezone,
          'timestamp': location.timestamp.toIso8601String(),
        };
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'location': locationData,
        }, SetOptions(merge: true));
      }

      log(
        '✅ Location updated in Firebase: ${location.latitude}, ${location.longitude}',
      );
    } catch (e) {
      log('❌ Error updating location in Firebase: $e');
    }
  }

  Future<void> _onSetManualLocation(
    SetManualLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final result = await getLocationFromCityCountry(
      city: event.city,
      country: event.country,
    );

    await result.fold(
      (failure) async {
        emit(LocationError(message: failure.message));
      },
      (location) async {
        // حفظ الموقع في LocationRefreshService
        if (location.latitude != null && location.longitude != null) {
          await locationRefreshService.saveCurrentLocation(
            location.latitude!,
            location.longitude!,
          );

          // تحديث الموقع في Firebase
          await _updateLocationInFirebase(location);
        }
        emit(LocationGranted(location: location));
      },
    );
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    final result = await saveLocation(event.location);

    result.fold(
      (failure) {
        emit(LocationError(message: failure.message));
      },
      (_) {
        emit(LocationGranted(location: event.location));
      },
    );
  }

  Future<void> _onClearLocation(
    ClearLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationInitial());
  }

  /// معالج التحديث التلقائي للموقع
  Future<void> _onRefreshLocationIfNeeded(
    RefreshLocationIfNeeded event,
    Emitter<LocationState> emit,
  ) async {
    try {
      log('🔄 Checking if location refresh is needed...');

      // إذا كان التحديث إجباري
      if (event.forceRefresh) {
        log('🔄 Force refresh requested');
        add(RequestLocationPermissionEvent());
        return;
      }

      // التحقق من تفعيل التحديث التلقائي
      if (!locationRefreshService.isAutoRefreshEnabled) {
        log('⚠️ Auto-refresh is disabled');
        return;
      }

      // If auto-refresh is enabled, ALWAYS request location update
      // This ensures we get the latest location and update Firebase
      log('📍 Auto-refresh enabled - requesting new location');
      add(RequestLocationPermissionEvent());
    } catch (e) {
      log('❌ Error in location refresh check: $e');
    }
  }

  StreamSubscription<Position>? _locationSubscription;

  Future<void> _onStartLocationUpdates(
    StartLocationUpdates event,
    Emitter<LocationState> emit,
  ) async {
    await _locationSubscription?.cancel();
    
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      return; 
    }
    
    log('📍 Starting foreground location updates (filter: 1000m)');
    
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 1000, 
      ),
    ).listen((position) {
      log('📍 Location changed significantly: ${position.latitude}, ${position.longitude}');
      add(GetCurrentLocationEvent());
    });
  }

  Future<void> _onStopLocationUpdates(
    StopLocationUpdates event,
    Emitter<LocationState> emit,
  ) async {
    log('🛑 Stopping foreground location updates');
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
