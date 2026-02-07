import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/prayer_times_entity.dart';

abstract class PrayerTimesEvent extends Equatable {
  const PrayerTimesEvent();

  @override
  List<Object?> get props => [];
}

class FetchPrayerTimes extends PrayerTimesEvent {
  final LocationEntity location;

  const FetchPrayerTimes({required this.location});

  @override
  List<Object?> get props => [location];
}

class LoadCachedPrayerTimes extends PrayerTimesEvent {}

class SwitchCalendarType extends PrayerTimesEvent {
  final CalendarType type;

  const SwitchCalendarType({required this.type});

  @override
  List<Object?> get props => [type];
}

class LoadMuezzins extends PrayerTimesEvent {}

class SetMuezzin extends PrayerTimesEvent {
  final String muezzinId;
  const SetMuezzin(this.muezzinId);
  @override
  List<Object?> get props => [muezzinId];
}

class ScheduleAthan extends PrayerTimesEvent {
  final PrayerTimesEntity prayerTimes;
  const ScheduleAthan(this.prayerTimes);
  @override
  List<Object?> get props => [prayerTimes];
}
