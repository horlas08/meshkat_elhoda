import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/collective_khatma_model.dart';

/// Remote data source for collective khatma operations
abstract class CollectiveKhatmaRemoteDataSource {
  Future<CollectiveKhatmaModel> createKhatma(CollectiveKhatmaModel khatma);
  Future<CollectiveKhatmaModel?> getKhatmaById(String khatmaId);
  Future<CollectiveKhatmaModel?> getKhatmaByInviteLink(String inviteLink);
  Future<void> updateKhatma(CollectiveKhatmaModel khatma);
  Future<List<CollectiveKhatmaModel>> getPublicKhatmas();
  Future<List<CollectiveKhatmaModel>> searchKhatmas(String query);
  Future<List<UserCollectiveKhatmaModel>> getUserKhatmas(String userId);
  Future<int> getUserCompletedKhatmasCount(String userId);
  Stream<CollectiveKhatmaModel?> watchKhatma(String khatmaId);
  Stream<List<CollectiveKhatmaModel>> watchPublicKhatmas();
  Future<void> deleteKhatma(String khatmaId);
  Future<void> addUserKhatmaRecord(
    String userId,
    UserCollectiveKhatmaModel record,
  );
  Future<void> updateUserKhatmaRecord(
    String userId,
    UserCollectiveKhatmaModel record,
  );
  Future<List<CollectiveKhatmaModel>> getUserCreatedKhatmas(String userId);
}

class CollectiveKhatmaRemoteDataSourceImpl
    implements CollectiveKhatmaRemoteDataSource {
  final FirebaseFirestore firestore;

  static const String _khatmasCollection = 'collective_khatmas';
  static const String _usersCollection = 'users';
  static const String _userKhatmasSubCollection = 'collective_khatmas';

  CollectiveKhatmaRemoteDataSourceImpl({required this.firestore});

  @override
  Future<CollectiveKhatmaModel> createKhatma(
    CollectiveKhatmaModel khatma,
  ) async {
    try {
      final docRef = firestore.collection(_khatmasCollection).doc(khatma.id);
      await docRef.set(khatma.toMap());
      log('✅ Collective khatma created: ${khatma.id}');
      return khatma;
    } catch (e) {
      log('❌ Error creating collective khatma: $e');
      rethrow;
    }
  }

  @override
  Future<CollectiveKhatmaModel?> getKhatmaById(String khatmaId) async {
    try {
      final doc = await firestore
          .collection(_khatmasCollection)
          .doc(khatmaId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return CollectiveKhatmaModel.fromFirestore(doc);
    } catch (e) {
      log('❌ Error getting khatma by ID: $e');
      rethrow;
    }
  }

  @override
  Future<CollectiveKhatmaModel?> getKhatmaByInviteLink(
    String inviteLink,
  ) async {
    try {
      final querySnapshot = await firestore
          .collection(_khatmasCollection)
          .where('inviteLink', isEqualTo: inviteLink)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return CollectiveKhatmaModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      log('❌ Error getting khatma by invite link: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateKhatma(CollectiveKhatmaModel khatma) async {
    try {
      await firestore
          .collection(_khatmasCollection)
          .doc(khatma.id)
          .update(khatma.toMap());
      log('✅ Collective khatma updated: ${khatma.id}');
    } catch (e) {
      log('❌ Error updating khatma: $e');
      rethrow;
    }
  }

  @override
  Future<List<CollectiveKhatmaModel>> getPublicKhatmas() async {
    try {
      final querySnapshot = await firestore
          .collection(_khatmasCollection)
          .where('type', isEqualTo: 'public')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => CollectiveKhatmaModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('❌ Error getting public khatmas: $e');
      rethrow;
    }
  }

  @override
  Future<List<CollectiveKhatmaModel>> searchKhatmas(String query) async {
    try {
      // Simple search - for production, consider using Algolia or Elasticsearch
      final querySnapshot = await firestore
          .collection(_khatmasCollection)
          .where('type', isEqualTo: 'public')
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => CollectiveKhatmaModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('❌ Error searching khatmas: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserCollectiveKhatmaModel>> getUserKhatmas(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_userKhatmasSubCollection)
          .orderBy('joinedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserCollectiveKhatmaModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      log('❌ Error getting user khatmas: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUserCompletedKhatmasCount(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_userKhatmasSubCollection)
          .where('status', isEqualTo: 'read')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      log('❌ Error getting completed khatmas count: $e');
      rethrow;
    }
  }

  @override
  Stream<CollectiveKhatmaModel?> watchKhatma(String khatmaId) {
    return firestore
        .collection(_khatmasCollection)
        .doc(khatmaId)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) {
            return null;
          }
          return CollectiveKhatmaModel.fromFirestore(doc);
        });
  }

  @override
  Stream<List<CollectiveKhatmaModel>> watchPublicKhatmas() {
    return firestore
        .collection(_khatmasCollection)
        .where('type', isEqualTo: 'public')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CollectiveKhatmaModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> deleteKhatma(String khatmaId) async {
    try {
      await firestore.collection(_khatmasCollection).doc(khatmaId).delete();
      log('✅ Collective khatma deleted: $khatmaId');
    } catch (e) {
      log('❌ Error deleting khatma: $e');
      rethrow;
    }
  }

  @override
  Future<void> addUserKhatmaRecord(
    String userId,
    UserCollectiveKhatmaModel record,
  ) async {
    try {
      await firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_userKhatmasSubCollection)
          .doc(record.khatmaId)
          .set(record.toMap());
      log('✅ User khatma record added: ${record.khatmaId}');
    } catch (e) {
      log('❌ Error adding user khatma record: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserKhatmaRecord(
    String userId,
    UserCollectiveKhatmaModel record,
  ) async {
    try {
      await firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_userKhatmasSubCollection)
          .doc(record.khatmaId)
          .update(record.toMap());
      log('✅ User khatma record updated: ${record.khatmaId}');
    } catch (e) {
      log('❌ Error updating user khatma record: $e');
      rethrow;
    }
  }

  @override
  Future<List<CollectiveKhatmaModel>> getUserCreatedKhatmas(
    String userId,
  ) async {
    try {
      final querySnapshot = await firestore
          .collection(_khatmasCollection)
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CollectiveKhatmaModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('❌ Error getting user created khatmas: $e');
      rethrow;
    }
  }
}
