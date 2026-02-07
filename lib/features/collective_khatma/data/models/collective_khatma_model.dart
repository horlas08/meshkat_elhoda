import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/collective_khatma_entity.dart';

/// Model for KhatmaPartEntity with Firestore serialization
class KhatmaPartModel extends KhatmaPartEntity {
  const KhatmaPartModel({
    required super.partNumber,
    super.userId,
    super.userName,
    super.status = PartStatus.notRead,
  });

  factory KhatmaPartModel.fromMap(Map<String, dynamic> map) {
    return KhatmaPartModel(
      partNumber: map['partNumber'] as int? ?? 1,
      userId: map['userId'] as String?,
      userName: map['userName'] as String?,
      status: map['status'] == 'read' ? PartStatus.read : PartStatus.notRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partNumber': partNumber,
      'userId': userId,
      'userName': userName,
      'status': status == PartStatus.read ? 'read' : 'not_read',
    };
  }

  KhatmaPartModel copyWith({
    int? partNumber,
    String? userId,
    String? userName,
    PartStatus? status,
  }) {
    return KhatmaPartModel(
      partNumber: partNumber ?? this.partNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
    );
  }

  factory KhatmaPartModel.initial(int partNumber) {
    return KhatmaPartModel(partNumber: partNumber, status: PartStatus.notRead);
  }
}

/// Model for CollectiveKhatmaEntity with Firestore serialization
class CollectiveKhatmaModel extends CollectiveKhatmaEntity {
  const CollectiveKhatmaModel({
    required super.id,
    required super.title,
    required super.createdBy,
    required super.creatorName,
    required super.type,
    required super.inviteLink,
    required super.startDate,
    required super.endDate,
    required super.parts,
    required super.createdAt,
    super.totalParts = 30,
  });

  factory CollectiveKhatmaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectiveKhatmaModel.fromMap(data, doc.id);
  }

  factory CollectiveKhatmaModel.fromMap(Map<String, dynamic> map, String id) {
    final partsData = map['parts'] as List<dynamic>? ?? [];
    final parts = partsData
        .map((p) => KhatmaPartModel.fromMap(p as Map<String, dynamic>))
        .toList();

    return CollectiveKhatmaModel(
      id: id,
      title: map['title'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      creatorName: map['creatorName'] as String? ?? '',
      type: map['type'] == 'public' ? KhatmaType.public : KhatmaType.private,
      inviteLink: map['inviteLink'] as String? ?? '',
      startDate: _parseDateTime(map['startDate']),
      endDate: _parseDateTime(map['endDate']),
      parts: parts,
      createdAt: _parseDateTime(map['createdAt']),
      totalParts: map['totalParts'] as int? ?? 30,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdBy': createdBy,
      'creatorName': creatorName,
      'type': type == KhatmaType.public ? 'public' : 'private',
      'inviteLink': inviteLink,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'parts': parts.map((p) => (p as KhatmaPartModel).toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'totalParts': totalParts,
    };
  }

  CollectiveKhatmaModel copyWith({
    String? id,
    String? title,
    String? createdBy,
    String? creatorName,
    KhatmaType? type,
    String? inviteLink,
    DateTime? startDate,
    DateTime? endDate,
    List<KhatmaPartEntity>? parts,
    DateTime? createdAt,
    int? totalParts,
  }) {
    return CollectiveKhatmaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      type: type ?? this.type,
      inviteLink: inviteLink ?? this.inviteLink,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      parts: parts ?? this.parts,
      createdAt: createdAt ?? this.createdAt,
      totalParts: totalParts ?? this.totalParts,
    );
  }

  /// Create a new khatma with initial 30 parts
  factory CollectiveKhatmaModel.create({
    required String title,
    required String createdBy,
    required String creatorName,
    required KhatmaType type,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final now = DateTime.now();
    final khatmaId = '${createdBy}_${now.millisecondsSinceEpoch}';
    final inviteLink = 'meshkat://khatma/$khatmaId';

    // Generate 30 parts
    final parts = List.generate(
      30,
      (index) => KhatmaPartModel.initial(index + 1),
    );

    return CollectiveKhatmaModel(
      id: khatmaId,
      title: title,
      createdBy: createdBy,
      creatorName: creatorName,
      type: type,
      inviteLink: inviteLink,
      startDate: startDate,
      endDate: endDate,
      parts: parts,
      createdAt: now,
      totalParts: 30,
    );
  }
}

/// Model for UserCollectiveKhatmaEntity
class UserCollectiveKhatmaModel extends UserCollectiveKhatmaEntity {
  const UserCollectiveKhatmaModel({
    required super.khatmaId,
    required super.khatmaTitle,
    required super.assignedPart,
    required super.status,
    required super.joinedAt,
    super.completedAt,
  });

  factory UserCollectiveKhatmaModel.fromMap(Map<String, dynamic> map) {
    return UserCollectiveKhatmaModel(
      khatmaId: map['khatmaId'] as String? ?? '',
      khatmaTitle: map['khatmaTitle'] as String? ?? '',
      assignedPart: map['assignedPart'] as int? ?? 1,
      status: map['status'] == 'read' ? PartStatus.read : PartStatus.notRead,
      joinedAt: _parseDateTime(map['joinedAt']),
      completedAt: map['completedAt'] != null
          ? _parseDateTime(map['completedAt'])
          : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'khatmaId': khatmaId,
      'khatmaTitle': khatmaTitle,
      'assignedPart': assignedPart,
      'status': status == PartStatus.read ? 'read' : 'not_read',
      'joinedAt': Timestamp.fromDate(joinedAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }
}
