import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/create_khatma_usecase.dart';
import '../../domain/usecases/join_khatma_usecase.dart';
import '../../domain/usecases/complete_part_usecase.dart';
import '../../domain/usecases/get_khatma_details_usecase.dart';
import '../../domain/usecases/get_public_khatmas_usecase.dart';
import '../../domain/usecases/get_user_collective_khatmas_usecase.dart';
import '../../domain/usecases/get_user_created_khatmas_usecase.dart';
import '../../domain/repositories/collective_khatma_repository.dart';
import 'collective_khatma_event.dart';
import 'package:meshkat_elhoda/core/services/collective_khatma_notification_service.dart';
import 'collective_khatma_state.dart';

class CollectiveKhatmaBloc
    extends Bloc<CollectiveKhatmaEvent, CollectiveKhatmaState> {
  final CreateKhatmaUseCase createKhatma;
  final JoinKhatmaUseCase joinKhatma;
  final CompletePartUseCase completePart;
  final GetKhatmaDetailsUseCase getKhatmaDetails;
  final GetKhatmaByInviteLinkUseCase getKhatmaByInviteLink;
  final GetPublicKhatmasUseCase getPublicKhatmas;
  final GetUserCollectiveKhatmasUseCase getUserCollectiveKhatmas;
  final GetUserCreatedKhatmasUseCase getUserCreatedKhatmas;
  final GetUserCompletedKhatmasCountUseCase getUserCompletedKhatmasCount;
  final GetUserReservedPartUseCase getUserReservedPart;
  final WatchKhatmaUseCase watchKhatma;
  final CollectiveKhatmaRepository repository;

  StreamSubscription? _khatmaSubscription;

  CollectiveKhatmaBloc({
    required this.createKhatma,
    required this.joinKhatma,
    required this.completePart,
    required this.getKhatmaDetails,
    required this.getKhatmaByInviteLink,
    required this.getPublicKhatmas,
    required this.getUserCollectiveKhatmas,
    required this.getUserCreatedKhatmas,
    required this.getUserCompletedKhatmasCount,
    required this.getUserReservedPart,
    required this.watchKhatma,
    required this.repository,
  }) : super(CollectiveKhatmaInitial()) {
    on<CreateKhatmaEvent>(_onCreateKhatma);
    on<LoadKhatmaDetailsEvent>(_onLoadKhatmaDetails);
    on<LoadKhatmaByInviteLinkEvent>(_onLoadKhatmaByInviteLink);
    on<JoinKhatmaEvent>(_onJoinKhatma);
    on<SelectPartEvent>(_onSelectPart);
    on<CompletePartEvent>(_onCompletePart);
    on<LoadPublicKhatmasEvent>(_onLoadPublicKhatmas);
    on<SearchKhatmasEvent>(_onSearchKhatmas);
    on<LoadUserCollectiveKhatmasEvent>(_onLoadUserKhatmas);
    on<LoadUserCreatedKhatmasEvent>(_onLoadUserCreatedKhatmas);
    on<WatchKhatmaEvent>(_onWatchKhatma);
    on<StopWatchingKhatmaEvent>(_onStopWatchingKhatma);
    on<KhatmaUpdatedEvent>(_onKhatmaUpdated);
    on<DeleteKhatmaEvent>(_onDeleteKhatma);
    on<LeaveKhatmaEvent>(_onLeaveKhatma);
  }

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _onCreateKhatma(
    CreateKhatmaEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    final user = _currentUser;
    if (user == null) {
      emit(const CollectiveKhatmaError('يجب تسجيل الدخول أولاً'));
      return;
    }

    emit(CollectiveKhatmaLoading());

    final result = await createKhatma(
      title: event.title,
      userId: user.uid,
      userName: user.displayName ?? 'مستخدم',
      type: event.type,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(CollectiveKhatmaError(failure.message)),
      (khatma) => emit(KhatmaCreated(khatma)),
    );
  }

  Future<void> _onLoadKhatmaDetails(
    LoadKhatmaDetailsEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    emit(CollectiveKhatmaLoading());

    final result = await getKhatmaDetails(event.khatmaId);

    await result.fold(
      (failure) async => emit(CollectiveKhatmaError(failure.message)),
      (khatma) async {
        int? userPart;
        final user = _currentUser;
        if (user != null) {
          final partResult = await getUserReservedPart(
            khatmaId: event.khatmaId,
            userId: user.uid,
          );
          partResult.fold(
            (failure) => log('Error getting user part: ${failure.message}'),
            (part) => userPart = part,
          );
        }
        emit(KhatmaLoaded(khatma: khatma, userReservedPart: userPart));
      },
    );
  }

  Future<void> _onLoadKhatmaByInviteLink(
    LoadKhatmaByInviteLinkEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    emit(CollectiveKhatmaLoading());

    final result = await getKhatmaByInviteLink(event.inviteLink);

    await result.fold(
      (failure) async => emit(CollectiveKhatmaError(failure.message)),
      (khatma) async {
        int? userPart;
        final user = _currentUser;
        if (user != null) {
          final partResult = await getUserReservedPart(
            khatmaId: khatma.id,
            userId: user.uid,
          );
          partResult.fold(
            (failure) => log('Error getting user part: ${failure.message}'),
            (part) => userPart = part,
          );
        }
        emit(KhatmaLoaded(khatma: khatma, userReservedPart: userPart));
      },
    );
  }

  Future<void> _onJoinKhatma(
    JoinKhatmaEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    final user = _currentUser;
    if (user == null) {
      emit(const CollectiveKhatmaError('يجب تسجيل الدخول أولاً'));
      return;
    }

    emit(CollectiveKhatmaLoading());

    final result = await joinKhatma(
      khatmaId: event.khatmaId,
      userId: user.uid,
      userName: user.displayName ?? 'مستخدم',
      partNumber: event.partNumber,
    );

    await result.fold(
      (failure) async => emit(CollectiveKhatmaError(failure.message)),
      (_) async {
        emit(
          KhatmaJoined(khatmaId: event.khatmaId, partNumber: event.partNumber),
        );
        // Reload khatma details
        add(LoadKhatmaDetailsEvent(event.khatmaId));

        // Update notifications
        await CollectiveKhatmaNotificationService().processBackgroundChecks();
      },
    );
  }

  void _onSelectPart(
    SelectPartEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) {
    if (state is KhatmaLoaded) {
      final currentState = state as KhatmaLoaded;
      emit(currentState.copyWith(selectedPart: event.partNumber));
    }
  }

  Future<void> _onCompletePart(
    CompletePartEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    final user = _currentUser;
    if (user == null) {
      emit(const CollectiveKhatmaError('يجب تسجيل الدخول أولاً'));
      return;
    }

    emit(CollectiveKhatmaLoading());

    final result = await completePart(
      khatmaId: event.khatmaId,
      userId: user.uid,
      partNumber: event.partNumber,
    );

    await result.fold(
      (failure) async => emit(CollectiveKhatmaError(failure.message)),
      (_) async {
        emit(
          PartCompleted(khatmaId: event.khatmaId, partNumber: event.partNumber),
        );
        // Reload khatma details
        add(LoadKhatmaDetailsEvent(event.khatmaId));

        // Update notifications (cancels completed part)
        await CollectiveKhatmaNotificationService().processBackgroundChecks();
      },
    );
  }

  Future<void> _onLoadPublicKhatmas(
    LoadPublicKhatmasEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    emit(CollectiveKhatmaLoading());

    final result = await getPublicKhatmas();

    result.fold(
      (failure) => emit(CollectiveKhatmaError(failure.message)),
      (khatmas) => emit(PublicKhatmasLoaded(khatmas)),
    );
  }

  Future<void> _onSearchKhatmas(
    SearchKhatmasEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadPublicKhatmasEvent());
      return;
    }

    emit(CollectiveKhatmaLoading());

    final result = await repository.searchKhatmas(event.query);

    result.fold(
      (failure) => emit(CollectiveKhatmaError(failure.message)),
      (khatmas) =>
          emit(KhatmaSearchResults(results: khatmas, query: event.query)),
    );
  }

  Future<void> _onLoadUserKhatmas(
    LoadUserCollectiveKhatmasEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    final user = _currentUser;
    if (user == null) {
      emit(const CollectiveKhatmaError('يجب تسجيل الدخول أولاً'));
      return;
    }

    emit(CollectiveKhatmaLoading());

    final khatmasResult = await getUserCollectiveKhatmas(user.uid);
    final countResult = await getUserCompletedKhatmasCount(user.uid);

    khatmasResult.fold(
      (failure) => emit(CollectiveKhatmaError(failure.message)),
      (khatmas) {
        final count = countResult.fold<int>((failure) => 0, (count) => count);
        emit(UserKhatmaListLoaded(khatmas: khatmas, completedCount: count));
      },
    );
  }

  Future<void> _onLoadUserCreatedKhatmas(
    LoadUserCreatedKhatmasEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    final user = _currentUser;
    if (user == null) {
      emit(const CollectiveKhatmaError('يجب تسجيل الدخول أولاً'));
      return;
    }

    emit(CollectiveKhatmaLoading());

    final result = await getUserCreatedKhatmas(user.uid);

    result.fold(
      (failure) => emit(CollectiveKhatmaError(failure.message)),
      (khatmas) => emit(UserCreatedKhatmasLoaded(khatmas)),
    );
  }

  void _onWatchKhatma(
    WatchKhatmaEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) {
    _khatmaSubscription?.cancel();
    _khatmaSubscription = watchKhatma(event.khatmaId).listen((result) {
      result.fold(
        (failure) => log('Watch error: ${failure.message}'),
        (khatma) => add(KhatmaUpdatedEvent(khatma)),
      );
    });
  }

  void _onStopWatchingKhatma(
    StopWatchingKhatmaEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) {
    _khatmaSubscription?.cancel();
    _khatmaSubscription = null;
  }

  void _onKhatmaUpdated(
    KhatmaUpdatedEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) {
    if (state is KhatmaLoaded) {
      final currentState = state as KhatmaLoaded;
      emit(currentState.copyWith(khatma: event.khatma));
    } else {
      emit(KhatmaLoaded(khatma: event.khatma));
    }
  }

  Future<void> _onDeleteKhatma(
    DeleteKhatmaEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    final user = _currentUser;
    if (user == null) {
      emit(const CollectiveKhatmaError('يجب تسجيل الدخول أولاً'));
      return;
    }

    emit(CollectiveKhatmaLoading());

    final result = await repository.deleteKhatma(
      khatmaId: event.khatmaId,
      userId: user.uid,
    );

    result.fold(
      (failure) => emit(CollectiveKhatmaError(failure.message)),
      (_) => emit(KhatmaDeleted(event.khatmaId)),
    );
  }

  Future<void> _onLeaveKhatma(
    LeaveKhatmaEvent event,
    Emitter<CollectiveKhatmaState> emit,
  ) async {
    final user = _currentUser;
    if (user == null) {
      emit(const CollectiveKhatmaError('يجب تسجيل الدخول أولاً'));
      return;
    }

    emit(CollectiveKhatmaLoading());

    final result = await repository.leaveKhatma(
      khatmaId: event.khatmaId,
      userId: user.uid,
      partNumber: event.partNumber,
    );

    await result.fold(
      (failure) async => emit(CollectiveKhatmaError(failure.message)),
      (_) async {
        add(LoadKhatmaDetailsEvent(event.khatmaId));
        // Cancel notifications for this part
        await CollectiveKhatmaNotificationService().cancelNotificationsForPart(
          khatmaId: event.khatmaId,
          partNumber: event.partNumber,
        );
      },
    );
  }

  @override
  Future<void> close() {
    _khatmaSubscription?.cancel();
    return super.close();
  }
}
