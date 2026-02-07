import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meshkat_elhoda/core/error/exceptions.dart';

/// خدمة مركزية للتعامل مع Firebase
/// توفر واجهة موحدة لجميع عمليات Firebase
class FirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _auth = auth,
       _firestore = firestore,
       _storage = storage;

  // ========== Auth Methods ==========

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'فشل تسجيل الدخول';
      int statusCode = 400;

      switch (e.code) {
        case 'too-many-requests':
          errorMessage =
              'تم تجاوز عدد المحاولات المسموح بها. يرجى المحاولة لاحقاً';
          statusCode = 429; // Too Many Requests
          break;
        case 'user-not-found':
        case 'wrong-password':
          errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
          break;
        case 'user-disabled':
          errorMessage = 'هذا الحساب معطل. يرجى التواصل مع الدعم الفني';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صالح';
          break;
        case 'network-request-failed':
          errorMessage = 'فشل الاتصال بالإنترنت. يرجى التحقق من اتصالك';
          statusCode = 503; // Service Unavailable
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }

      throw ServerException(message: errorMessage, statusCode: statusCode);
    } catch (e) {
      throw ServerException(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
        statusCode: 500,
      );
    }
  }

  /// إنشاء حساب جديد
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw ServerException(
        message: e.message ?? 'فشل إنشاء الحساب',
        statusCode: 400,
      );
    } catch (e) {
      throw ServerException(message: 'حدث خطأ غير متوقع: $e', statusCode: 500);
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// إرسال بريد التحقق
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// الحصول على معرف المستخدم الحالي
  String? get currentUserId => _auth.currentUser?.uid;

  /// التحقق من حالة المصادقة
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ========== Firestore Methods ==========

  /// الحصول على مستند من Firestore
  Future<Map<String, dynamic>> getDocument(
    String collection,
    String docId,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (!doc.exists) {
        throw ServerException(message: 'Document not found', statusCode: 404);
      }
      return doc.data()!;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'فشل جلب المستند',
        statusCode: 500,
      );
    }
  }

  /// إضافة مستند جديد إلى Firestore
  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      if (data['uid'] != null) {
        await _firestore.collection(collection).doc(data['uid']).set(data);
      } else {
        await _firestore.collection(collection).add(data);
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'فشل إضافة المستند',
        statusCode: 500,
      );
    }
  }

  /// تحديث مستند موجود في Firestore
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'فشل تحديث المستند',
        statusCode: 500,
      );
    }
  }

  /// حذف مستند من Firestore
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'فشل حذف المستند',
        statusCode: 500,
      );
    }
  }

  /// تسجيل الدخول كضيف
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw ServerException(
        message: e.message ?? 'فشل تسجيل الدخول كضيف',
        statusCode: 400,
      );
    } catch (e) {
      throw ServerException(message: 'حدث خطأ غير متوقع: $e', statusCode: 500);
    }
  }

  // ========== Storage Methods ==========
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get download URL',
        statusCode: 500,
      );
    }
  }
}
