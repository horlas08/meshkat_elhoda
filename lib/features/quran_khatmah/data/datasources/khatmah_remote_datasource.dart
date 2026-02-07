import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import '../models/khatmah_progress_model.dart';

abstract class KhatmahRemoteDataSource {
  Future<KhatmahProgressModel?> getUserKhatmahProgress(String userId);
  Future<void> updateKhatmahProgress(
    String userId,
    KhatmahProgressModel progress,
  );
  Future<void> resetKhatmahProgress(String userId);
}

class KhatmahRemoteDataSourceImpl implements KhatmahRemoteDataSource {
  final FirebaseFirestore firestore;

  KhatmahRemoteDataSourceImpl({required this.firestore});

  @override
  Future<KhatmahProgressModel?> getUserKhatmahProgress(String userId) async {
    print('🔥 KhatmahRemoteDataSourceImpl: Getting doc for $userId');
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('khatma')
          .doc('progress')
          .get();

      if (!doc.exists || doc.data() == null) {
        log(
          '📖 No khatmah progress found for user $userId - returning initial',
        );
        return null; // Return null to indicate no saved progress
      }

      final progress = KhatmahProgressModel.fromMap(doc.data()!);
      log('📖 Loaded khatmah progress: $progress');
      return progress;
    } catch (e) {
      log('❌ Error loading khatmah progress: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateKhatmahProgress(
    String userId,
    KhatmahProgressModel progress,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('khatma')
          .doc('progress')
          .set(progress.toMap(), SetOptions(merge: true));

      log('✅ Khatmah progress updated: ${progress.currentPage}/604');
    } catch (e) {
      log('❌ Error updating khatmah progress: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetKhatmahProgress(String userId) async {
    try {
      final initialProgress = KhatmahProgressModel.initial();
      await updateKhatmahProgress(userId, initialProgress);
      log('🔄 Khatmah progress reset to page 1');
    } catch (e) {
      log('❌ Error resetting khatmah progress: $e');
      rethrow;
    }
  }
}
