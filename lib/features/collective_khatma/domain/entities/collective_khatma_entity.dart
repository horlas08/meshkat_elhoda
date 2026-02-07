import 'package:equatable/equatable.dart';

/// Enum representing the status of a Quran part in the collective khatma
enum PartStatus { notRead, read }

/// Enum representing the type of khatma (public or private)
enum KhatmaType { public, private }

/// Entity representing a single part (juz) in the collective khatma
class KhatmaPartEntity extends Equatable {
  final int partNumber;
  final String? userId;
  final String? userName;
  final PartStatus status;

  const KhatmaPartEntity({
    required this.partNumber,
    this.userId,
    this.userName,
    this.status = PartStatus.notRead,
  });

  bool get isReserved => userId != null;
  bool get isCompleted => status == PartStatus.read;

  @override
  List<Object?> get props => [partNumber, userId, userName, status];
}

/// Main entity representing a collective khatma
class CollectiveKhatmaEntity extends Equatable {
  final String id;
  final String title;
  final String createdBy;
  final String creatorName;
  final KhatmaType type;
  final String inviteLink;
  final DateTime startDate;
  final DateTime endDate;
  final List<KhatmaPartEntity> parts;
  final DateTime createdAt;
  final int totalParts;

  const CollectiveKhatmaEntity({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.creatorName,
    required this.type,
    required this.inviteLink,
    required this.startDate,
    required this.endDate,
    required this.parts,
    required this.createdAt,
    this.totalParts = 30,
  });

  /// Calculate progress percentage (0.0 - 1.0)
  double get progressPercentage {
    if (parts.isEmpty) return 0.0;
    final completedParts = parts.where((p) => p.isCompleted).length;
    return completedParts / totalParts;
  }

  /// Get number of completed parts
  int get completedPartsCount => parts.where((p) => p.isCompleted).length;

  /// Get number of reserved parts
  int get reservedPartsCount => parts.where((p) => p.isReserved).length;

  /// Get number of available parts
  int get availablePartsCount => parts.where((p) => !p.isReserved).length;

  /// Get remaining parts count
  int get remainingPartsCount => totalParts - completedPartsCount;

  /// Check if khatma is complete
  bool get isComplete => completedPartsCount == totalParts;

  /// Check if khatma is expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Check if khatma is active (started and not expired)
  bool get isActive => DateTime.now().isAfter(startDate) && !isExpired;

  /// Get days remaining until end date
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Get participants count
  int get participantsCount {
    final uniqueUsers = parts
        .where((p) => p.userId != null)
        .map((p) => p.userId!)
        .toSet();
    return uniqueUsers.length;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    createdBy,
    creatorName,
    type,
    inviteLink,
    startDate,
    endDate,
    parts,
    createdAt,
    totalParts,
  ];
}

/// Entity representing user's participation in collective khatmas
class UserCollectiveKhatmaEntity extends Equatable {
  final String khatmaId;
  final String khatmaTitle;
  final int assignedPart;
  final PartStatus status;
  final DateTime joinedAt;
  final DateTime? completedAt;

  const UserCollectiveKhatmaEntity({
    required this.khatmaId,
    required this.khatmaTitle,
    required this.assignedPart,
    required this.status,
    required this.joinedAt,
    this.completedAt,
  });

  bool get isCompleted => status == PartStatus.read;

  @override
  List<Object?> get props => [
    khatmaId,
    khatmaTitle,
    assignedPart,
    status,
    joinedAt,
    completedAt,
  ];
}
