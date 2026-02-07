import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/get_user_collective_khatmas_usecase.dart';
import '../../domain/entities/collective_khatma_entity.dart';

abstract class UserJoinedKhatmasEvent {}

class LoadUserJoinedKhatmasEvent extends UserJoinedKhatmasEvent {}

class RefreshUserJoinedKhatmasEvent extends UserJoinedKhatmasEvent {}

abstract class UserJoinedKhatmasState {}

class UserJoinedInitial extends UserJoinedKhatmasState {}

class UserJoinedLoading extends UserJoinedKhatmasState {}

class UserJoinedError extends UserJoinedKhatmasState {
  final String message;

  UserJoinedError(this.message);
}

class UserJoinedLoaded extends UserJoinedKhatmasState {
  final List<UserCollectiveKhatmaEntity> khatmas;
  final int completedCount;

  UserJoinedLoaded({required this.khatmas, required this.completedCount});
}

class UserJoinedKhatmasBloc
    extends Bloc<UserJoinedKhatmasEvent, UserJoinedKhatmasState> {
  final GetUserCollectiveKhatmasUseCase getUserCollectiveKhatmas;

  UserJoinedKhatmasBloc({required this.getUserCollectiveKhatmas})
    : super(UserJoinedInitial()) {
    on<LoadUserJoinedKhatmasEvent>(_onLoad);
    on<RefreshUserJoinedKhatmasEvent>(_onLoad);
  }

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _onLoad(
    UserJoinedKhatmasEvent event,
    Emitter<UserJoinedKhatmasState> emit,
  ) async {
    final user = _currentUser;
    if (user == null) {
      emit(UserJoinedError('يجب تسجيل الدخول أولاً'));
      return;
    }

    emit(UserJoinedLoading());

    final khatmasResult = await getUserCollectiveKhatmas(user.uid);

    khatmasResult.fold((failure) => emit(UserJoinedError(failure.message)), (
      khatmas,
    ) {
      emit(UserJoinedLoaded(khatmas: khatmas, completedCount: 0));
    });
  }
}
