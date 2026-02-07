import 'package:equatable/equatable.dart';

abstract class KhatmaProgressEvent extends Equatable {
  const KhatmaProgressEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل تقدم الختمة
class LoadKhatmaProgress extends KhatmaProgressEvent {}

/// تحديث تقدم الختمة
class UpdateKhatmaProgress extends KhatmaProgressEvent {
  final int page;
  final int juz;
  final int hizb;

  const UpdateKhatmaProgress({
    required this.page,
    required this.juz,
    required this.hizb,
  });

  @override
  List<Object?> get props => [page, juz, hizb];
}

/// إعادة تعيين الختمة
class ResetKhatmaProgress extends KhatmaProgressEvent {}
