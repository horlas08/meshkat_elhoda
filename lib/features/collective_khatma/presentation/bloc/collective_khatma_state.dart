import 'package:equatable/equatable.dart';
import '../../domain/entities/collective_khatma_entity.dart';

abstract class CollectiveKhatmaState extends Equatable {
  const CollectiveKhatmaState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CollectiveKhatmaInitial extends CollectiveKhatmaState {}

/// Loading state
class CollectiveKhatmaLoading extends CollectiveKhatmaState {}

/// Khatma created successfully
class KhatmaCreated extends CollectiveKhatmaState {
  final CollectiveKhatmaEntity khatma;

  const KhatmaCreated(this.khatma);

  @override
  List<Object?> get props => [khatma];
}

/// User joined a khatma successfully
class KhatmaJoined extends CollectiveKhatmaState {
  final String khatmaId;
  final int partNumber;

  const KhatmaJoined({required this.khatmaId, required this.partNumber});

  @override
  List<Object?> get props => [khatmaId, partNumber];
}

/// Khatma details loaded
class KhatmaLoaded extends CollectiveKhatmaState {
  final CollectiveKhatmaEntity khatma;
  final int? userReservedPart;
  final int? selectedPart;

  const KhatmaLoaded({
    required this.khatma,
    this.userReservedPart,
    this.selectedPart,
  });

  KhatmaLoaded copyWith({
    CollectiveKhatmaEntity? khatma,
    int? userReservedPart,
    int? selectedPart,
  }) {
    return KhatmaLoaded(
      khatma: khatma ?? this.khatma,
      userReservedPart: userReservedPart ?? this.userReservedPart,
      selectedPart: selectedPart ?? this.selectedPart,
    );
  }

  @override
  List<Object?> get props => [khatma, userReservedPart, selectedPart];
}

/// Public khatmas list loaded
class PublicKhatmasLoaded extends CollectiveKhatmaState {
  final List<CollectiveKhatmaEntity> khatmas;

  const PublicKhatmasLoaded(this.khatmas);

  @override
  List<Object?> get props => [khatmas];
}

/// User's collective khatmas loaded
class UserKhatmaListLoaded extends CollectiveKhatmaState {
  final List<UserCollectiveKhatmaEntity> khatmas;
  final int completedCount;

  const UserKhatmaListLoaded({
    required this.khatmas,
    required this.completedCount,
  });

  @override
  List<Object?> get props => [khatmas, completedCount];
}

/// Part completed successfully
class PartCompleted extends CollectiveKhatmaState {
  final String khatmaId;
  final int partNumber;

  const PartCompleted({required this.khatmaId, required this.partNumber});

  @override
  List<Object?> get props => [khatmaId, partNumber];
}

/// Khatma deleted successfully
class KhatmaDeleted extends CollectiveKhatmaState {
  final String khatmaId;

  const KhatmaDeleted(this.khatmaId);

  @override
  List<Object?> get props => [khatmaId];
}

/// Search results
class KhatmaSearchResults extends CollectiveKhatmaState {
  final List<CollectiveKhatmaEntity> results;
  final String query;

  const KhatmaSearchResults({required this.results, required this.query});

  @override
  List<Object?> get props => [results, query];
}

/// User's created khatmas loaded
class UserCreatedKhatmasLoaded extends CollectiveKhatmaState {
  final List<CollectiveKhatmaEntity> khatmas;

  const UserCreatedKhatmasLoaded(this.khatmas);

  @override
  List<Object?> get props => [khatmas];
}

/// Error state
class CollectiveKhatmaError extends CollectiveKhatmaState {
  final String message;

  const CollectiveKhatmaError(this.message);

  @override
  List<Object?> get props => [message];
}
