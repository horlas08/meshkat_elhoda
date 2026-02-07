import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meshkat_elhoda/features/quran_index/data/models/khatma_progress_model.dart';
import 'dart:developer';

/// مصدر البيانات لتقدم الختمة من Firebase
abstract class KhatmaProgressDataSource {
  Future<KhatmaProgressModel?> getUserKhatmaProgress(String userId);
  Future<void> updateKhatmaProgress(
    String userId,
    KhatmaProgressModel progress,
  );
  Future<void> resetKhatmaProgress(String userId);
}

class KhatmaProgressDataSourceImpl implements KhatmaProgressDataSource {
  final FirebaseFirestore firestore;

  KhatmaProgressDataSourceImpl({required this.firestore});

  @override
  Future<KhatmaProgressModel?> getUserKhatmaProgress(String userId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('khatma')
          .doc('progress')
          .get();

      if (!doc.exists || doc.data() == null) {
        log('📖 No khatma progress found for user $userId - returning initial');
        return null;
      }

      final progress = KhatmaProgressModel.fromMap(doc.data()!);
      log('📖 Loaded khatma progress: $progress');
      return progress;
    } catch (e) {
      log('❌ Error loading khatma progress: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateKhatmaProgress(
    String userId,
    KhatmaProgressModel progress,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('khatma')
          .doc('progress')
          .set(progress.toMap(), SetOptions(merge: true));

      log('✅ Khatma progress updated: ${progress.currentPage}/604');
    } catch (e) {
      log('❌ Error updating khatma progress: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetKhatmaProgress(String userId) async {
    try {
      final initialProgress = KhatmaProgressModel.initial();
      await updateKhatmaProgress(userId, initialProgress);
      log('🔄 Khatma progress reset to page 1');
    } catch (e) {
      log('❌ Error resetting khatma progress: $e');
      rethrow;
    }
  }
}
