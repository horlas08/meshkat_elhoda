import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meshkat_elhoda/features/mosques/domain/usecases/get_nearby_mosques.dart'
    as usecase;
import 'mosque_event.dart';
import 'mosque_state.dart';

class MosqueBloc extends Bloc<MosqueEvent, MosqueState> {
  final usecase.GetNearbyMosques getNearbyMosques;

  MosqueBloc({required this.getNearbyMosques}) : super(const MosqueInitial()) {
    on<GetNearbyMosques>(_onGetNearbyMosques);
  }

  Future<void> _onGetNearbyMosques(
    GetNearbyMosques event,
    Emitter<MosqueState> emit,
  ) async {
    emit(const MosqueLoading());
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        emit(const MosqueError('تم رفض صلاحية الموقع. يرجى منح الإذن.'));
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15),
      );

      final result = await getNearbyMosques(
        usecase.Params(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      result.fold(
        (failure) => emit(MosqueError(failure.message)),
        (mosques) => emit(
          MosqueLoaded(
            mosques: mosques,
            userLatitude: position.latitude,
            userLongitude: position.longitude,
          ),
        ),
      );
    } catch (e) {
      emit(MosqueError(e.toString()));
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
