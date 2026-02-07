import 'package:equatable/equatable.dart';
import '../../domain/entities/collective_khatma_entity.dart';

abstract class CollectiveKhatmaEvent extends Equatable {
  const CollectiveKhatmaEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a new collective khatma
class CreateKhatmaEvent extends CollectiveKhatmaEvent {
  final String title;
  final KhatmaType type;
  final DateTime startDate;
  final DateTime endDate;

  const CreateKhatmaEvent({
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [title, type, startDate, endDate];
}

/// Event to load khatma details
class LoadKhatmaDetailsEvent extends CollectiveKhatmaEvent {
  final String khatmaId;

  const LoadKhatmaDetailsEvent(this.khatmaId);

  @override
  List<Object?> get props => [khatmaId];
}

/// Event to load khatma by invite link
class LoadKhatmaByInviteLinkEvent extends CollectiveKhatmaEvent {
  final String inviteLink;

  const LoadKhatmaByInviteLinkEvent(this.inviteLink);

  @override
  List<Object?> get props => [inviteLink];
}

/// Event to join a khatma (select a part)
class JoinKhatmaEvent extends CollectiveKhatmaEvent {
  final String khatmaId;
  final int partNumber;

  const JoinKhatmaEvent({required this.khatmaId, required this.partNumber});

  @override
  List<Object?> get props => [khatmaId, partNumber];
}

/// Event to select a part (different from joining)
class SelectPartEvent extends CollectiveKhatmaEvent {
  final int partNumber;

  const SelectPartEvent(this.partNumber);

  @override
  List<Object?> get props => [partNumber];
}

/// Event to complete a part
class CompletePartEvent extends CollectiveKhatmaEvent {
  final String khatmaId;
  final int partNumber;

  const CompletePartEvent({required this.khatmaId, required this.partNumber});

  @override
  List<Object?> get props => [khatmaId, partNumber];
}

/// Event to load public khatmas list
class LoadPublicKhatmasEvent extends CollectiveKhatmaEvent {}

/// Event to search khatmas
class SearchKhatmasEvent extends CollectiveKhatmaEvent {
  final String query;

  const SearchKhatmasEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to load user's collective khatmas
class LoadUserCollectiveKhatmasEvent extends CollectiveKhatmaEvent {}

/// Event to start watching a khatma in real-time
class WatchKhatmaEvent extends CollectiveKhatmaEvent {
  final String khatmaId;

  const WatchKhatmaEvent(this.khatmaId);

  @override
  List<Object?> get props => [khatmaId];
}

/// Event to stop watching a khatma
class StopWatchingKhatmaEvent extends CollectiveKhatmaEvent {}

/// Internal event for real-time updates
class KhatmaUpdatedEvent extends CollectiveKhatmaEvent {
  final CollectiveKhatmaEntity khatma;

  const KhatmaUpdatedEvent(this.khatma);

  @override
  List<Object?> get props => [khatma];
}

/// Event to delete a khatma
class DeleteKhatmaEvent extends CollectiveKhatmaEvent {
  final String khatmaId;

  const DeleteKhatmaEvent(this.khatmaId);

  @override
  List<Object?> get props => [khatmaId];
}

/// Event to leave a khatma
class LeaveKhatmaEvent extends CollectiveKhatmaEvent {
  final String khatmaId;
  final int partNumber;

  const LeaveKhatmaEvent({required this.khatmaId, required this.partNumber});

  @override
  List<Object?> get props => [khatmaId, partNumber];
}

/// Event to load user's created khatmas
class LoadUserCreatedKhatmasEvent extends CollectiveKhatmaEvent {}
