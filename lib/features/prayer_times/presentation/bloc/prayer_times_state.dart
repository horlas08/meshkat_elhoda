import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/prayer_times_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/muezzin.dart';

abstract class PrayerTimesState extends Equatable {
  const PrayerTimesState();

  @override
  List<Object?> get props => [];
}

class PrayerTimesInitial extends PrayerTimesState {}

class PrayerTimesLoading extends PrayerTimesState {}

class PrayerTimesLoaded extends PrayerTimesState {
  final PrayerTimesEntity? prayerTimes;
  final CalendarType calendarType;
  final bool isFromCache;
  final List<Muezzin> muezzins;
  final String? selectedMuezzinId;

  const PrayerTimesLoaded({
    this.prayerTimes,
    this.calendarType = CalendarType.hijri,
    this.isFromCache = false,
    this.muezzins = const [],
    this.selectedMuezzinId,
  });

  PrayerTimesLoaded copyWith({
    PrayerTimesEntity? prayerTimes,
    CalendarType? calendarType,
    bool? isFromCache,
    List<Muezzin>? muezzins,
    String? selectedMuezzinId,
  }) {
    return PrayerTimesLoaded(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      calendarType: calendarType ?? this.calendarType,
      isFromCache: isFromCache ?? this.isFromCache,
      muezzins: muezzins ?? this.muezzins,
      selectedMuezzinId: selectedMuezzinId ?? this.selectedMuezzinId,
    );
  }

  @override
  List<Object?> get props => [
    prayerTimes,
    calendarType,
    isFromCache,
    muezzins,
    selectedMuezzinId,
  ];
}

class PrayerTimesError extends PrayerTimesState {
  final String message;

  const PrayerTimesError({required this.message});

  @override
  List<Object?> get props => [message];
}
