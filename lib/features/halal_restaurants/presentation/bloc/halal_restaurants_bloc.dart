import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/domain/usecases/get_nearby_halal_restaurants.dart'
    as usecase;
import 'halal_restaurants_event.dart';
import 'halal_restaurants_state.dart';

class HalalRestaurantsBloc
    extends Bloc<HalalRestaurantsEvent, HalalRestaurantsState> {
  final usecase.GetNearbyHalalRestaurants getNearbyHalalRestaurants;

  HalalRestaurantsBloc({required this.getNearbyHalalRestaurants})
      : super(const HalalRestaurantsInitial()) {
    on<GetNearbyHalalRestaurantsEvent>(_onGetNearbyHalalRestaurants);
  }

  Future<void> _onGetNearbyHalalRestaurants(
    GetNearbyHalalRestaurantsEvent event,
    Emitter<HalalRestaurantsState> emit,
  ) async {
    emit(const HalalRestaurantsLoading());
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        emit(const HalalRestaurantsError('تم رفض صلاحية الموقع. يرجى منح الإذن.'));
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final result = await getNearbyHalalRestaurants(
        usecase.Params(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      result.fold(
        (failure) => emit(HalalRestaurantsError(failure.message)),
        (restaurants) => emit(
          HalalRestaurantsLoaded(
            restaurants: restaurants,
            userLatitude: position.latitude,
            userLongitude: position.longitude,
          ),
        ),
      );
    } catch (e) {
      emit(HalalRestaurantsError(e.toString()));
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}
