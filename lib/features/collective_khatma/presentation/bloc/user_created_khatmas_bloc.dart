import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/get_user_created_khatmas_usecase.dart';
import '../../domain/entities/collective_khatma_entity.dart';

abstract class UserCreatedKhatmasEvent {}

class LoadUserCreatedTabEvent extends UserCreatedKhatmasEvent {}

class RefreshUserCreatedTabEvent extends UserCreatedKhatmasEvent {}

abstract class UserCreatedKhatmasState {}

class UserCreatedInitial extends UserCreatedKhatmasState {}

class UserCreatedLoading extends UserCreatedKhatmasState {}

class UserCreatedError extends UserCreatedKhatmasState {
  final String message;

  UserCreatedError(this.message);
}

class UserCreatedLoaded extends UserCreatedKhatmasState {
  final List<CollectiveKhatmaEntity> khatmas;

  UserCreatedLoaded(this.khatmas);
}

class UserCreatedKhatmasBloc
    extends Bloc<UserCreatedKhatmasEvent, UserCreatedKhatmasState> {
  final GetUserCreatedKhatmasUseCase getUserCreatedKhatmas;

  UserCreatedKhatmasBloc({required this.getUserCreatedKhatmas})
    : super(UserCreatedInitial()) {
    on<LoadUserCreatedTabEvent>(_onLoad);
    on<RefreshUserCreatedTabEvent>(_onLoad);
  }

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _onLoad(
    UserCreatedKhatmasEvent event,
    Emitter<UserCreatedKhatmasState> emit,
  ) async {
    final user = _currentUser;
    if (user == null) {
      emit(UserCreatedError('يجب تسجيل الدخول أولاً'));
      return;
    }

    emit(UserCreatedLoading());

    final result = await getUserCreatedKhatmas(user.uid);

    result.fold(
      (failure) => emit(UserCreatedError(failure.message)),
      (khatmas) => emit(UserCreatedLoaded(khatmas)),
    );
  }
}
