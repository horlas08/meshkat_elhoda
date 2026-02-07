import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meshkat_elhoda/features/quran_index/data/models/khatma_progress_model.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/repositories/khatma_progress_repository.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/khatma_progress_event.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/khatma_progress_state.dart';
import 'dart:developer';

class KhatmaProgressBloc
    extends Bloc<KhatmaProgressEvent, KhatmaProgressState> {
  final KhatmaProgressRepository repository;

  KhatmaProgressBloc({required this.repository}) : super(KhatmaInitial()) {
    on<LoadKhatmaProgress>(_onLoadKhatmaProgress);
    on<UpdateKhatmaProgress>(_onUpdateKhatmaProgress);
    on<ResetKhatmaProgress>(_onResetKhatmaProgress);
  }

  Future<void> _onLoadKhatmaProgress(
    LoadKhatmaProgress event,
    Emitter<KhatmaProgressState> emit,
  ) async {
    emit(KhatmaLoading());

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const KhatmaError(message: 'User not logged in'));
      return;
    }

    final result = await repository.getUserKhatmaProgress(user.uid);

    result.fold(
      (failure) => emit(KhatmaError(message: failure.message)),
      (progress) => emit(KhatmaLoaded(progress: progress)),
    );
  }

  Future<void> _onUpdateKhatmaProgress(
    UpdateKhatmaProgress event,
    Emitter<KhatmaProgressState> emit,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // الحصول على الحالة الحالية
    KhatmaProgressModel currentProgress;
    if (state is KhatmaLoaded) {
      currentProgress = (state as KhatmaLoaded).progress;
    } else {
      currentProgress = KhatmaProgressModel.initial();
    }

    // تحديث النموذج
    final newProgress = currentProgress.copyWith(
      currentPage: event.page,
      currentJuz: event.juz,
      currentHizb: event.hizb,
      lastUpdated: DateTime.now(),
    );

    // تحديث الواجهة فوراً (Optimistic Update)
    emit(KhatmaLoaded(progress: newProgress));

    // حفظ في Firebase
    final result = await repository.updateKhatmaProgress(user.uid, newProgress);

    result.fold((failure) {
      log('❌ Error updating khatma progress: ${failure.message}');
      // يمكن إضافة منطق للتراجع عن التحديث إذا فشل
    }, (_) => log('✅ Khatma progress saved to Firebase'));
  }

  Future<void> _onResetKhatmaProgress(
    ResetKhatmaProgress event,
    Emitter<KhatmaProgressState> emit,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    emit(KhatmaLoading());

    final result = await repository.resetKhatmaProgress(user.uid);

    result.fold(
      (failure) => emit(KhatmaError(message: failure.message)),
      (_) => emit(KhatmaLoaded(progress: KhatmaProgressModel.initial())),
    );
  }
}
