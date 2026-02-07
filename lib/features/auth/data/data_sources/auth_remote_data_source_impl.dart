import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meshkat_elhoda/core/network/firebase_service.dart';
import 'package:meshkat_elhoda/features/auth/data/models/user_model.dart';
import 'package:meshkat_elhoda/features/location/data/data_sources/location_remote_data_source.dart';
import 'package:meshkat_elhoda/features/location/data/models/location_model.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:permission_handler/permission_handler.dart';
import 'auth_remote_data_source.dart';
import 'package:meshkat_elhoda/features/auth/domain/entities/user_entity.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseService _firebaseService;
  final LocationRemoteDataSource _locationRemoteDataSource;

  AuthRemoteDataSourceImpl({
    required FirebaseService firebaseService,
    required LocationRemoteDataSource locationRemoteDataSource,
  }) : _firebaseService = firebaseService,
       _locationRemoteDataSource = locationRemoteDataSource;

  @override
  Future<bool> isSignedIn() async {
    final currentUser = _firebaseService.currentUser;
    return currentUser != null;
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential.user == null) {
        throw Exception('فشل تسجيل الدخول');
      }

      // حفظ التوكن
      await _saveDeviceToken(userCredential.user!.uid);

      // الحصول على بيانات المستخدم من Firestore
      final userData = await _firebaseService.getDocument(
        'users',
        userCredential.user!.uid,
      );

      // ✅ تحديث displayName إذا كان فارغاً
      if (userCredential.user!.displayName == null ||
          userCredential.user!.displayName!.isEmpty) {
        final name = userData['name'] as String?;
        if (name != null && name.isNotEmpty) {
          await userCredential.user!.updateDisplayName(name);
          await userCredential.user!.reload();
        }
      }

      return UserModel.fromJson(userData);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String language,
    bool sendVerificationEmail = false,
  }) async {
    try {
      // 1. الحصول على الموقع الحالي للمستخدم
      LocationModel userLocation = await _getUserLocationWithFallback(language);

      // 2. إنشاء المستخدم في Firebase Auth
      final userCredential = await _firebaseService.signUpWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential.user == null) {
        throw Exception('فشل إنشاء المستخدم: لا يوجد مستخدم');
      }

      final user = userCredential.user!;

      // ✅ تحديث اسم المستخدم في Firebase Auth
      await user.updateDisplayName(name);
      await user.reload(); // إعادة تحميل بيانات المستخدم

      // 3. إنشاء بيانات المستخدم لـ Firestore
      final userData = {
        'uid': user.uid,
        'name': name,
        'email': email,
        'language': language,
        'country': userLocation.country,
        'city': userLocation.city ?? _getDefaultCity(userLocation.country!),
        'location': userLocation.toJson(), // ← حفظ بيانات الموقع الكاملة
        'emailVerified': user.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'subscription': {'type': 'free', 'expiresAt': null},
      };

      // 4. حفظ بيانات المستخدم في Firestore
      await _firebaseService.addDocument('users', userData);
      await _saveDeviceToken(user.uid); // 👈 أضف هذا السطر

      // 6. إرجاع نموذج المستخدم المنشأ
      return UserModel.fromJson({
        ...userData,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Log the error for debugging
      print('Error during sign up: $e');

      // Clean up if user was created but Firestore operation failed
      if (e is! FirebaseAuthException) {
        final currentUser = _firebaseService.currentUser;
        if (currentUser != null) {
          await currentUser.delete();
        }
      }

      rethrow;
    }
  }

  @override
  Future<UserModel> signInAnonymously() async {
    try {
      final userCredential = await _firebaseService.signInAnonymously();

      if (userCredential.user == null) {
        throw Exception('فشل تسجيل الدخول كضيف');
      }

      final deviceLocale = ui.window.locale.languageCode;

      // 1. الحصول على الموقع الحالي للمستخدم
      LocationModel userLocation = await _getUserLocationWithFallback(
        deviceLocale,
      );

      // 2. إنشاء مستخدم ضيف ببيانات الموقع الدقيقة
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        name: 'ضيف',
        email: 'guest@example.com',
        language: deviceLocale,
        country: userLocation.country!,
        city: userLocation.city ?? _getDefaultCity(userLocation.country!),
        location: userLocation, // ← حفظ بيانات الموقع الكاملة
        subscription: SubscriptionEntity(type: 'free', expiresAt: null),
        createdAt: DateTime.now(),
      );

      // 3. حفظ بيانات المستخدم في Firestore
      await _firebaseService.addDocument('users', userModel.toJson());
      await _saveDeviceToken(userCredential.user!.uid); // 👈 أضف هذا السطر

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('فشل تسجيل الدخول كضيف: $e');
    }
  }

  // دالة مساعدة للحصول على موقع المستخدم مع وجود بديل إذا فشل
  Future<LocationModel> _getUserLocationWithFallback(String language) async {
    try {
      final permissionStatus = await _locationRemoteDataSource
          .requestLocationPermission();

      if (permissionStatus.isGranted) {
        final location = await _locationRemoteDataSource.getCurrentLocation();

        // إذا كانت المدينة والبلد null (بسبب عدم التطابق)، نطلب من المستخدم إدخالها
        if (location.country == null || location.city == null) {
          print(
            '📍 جلب الموقع نجح لكن بدون مدينة/بلد، نستخدم القيم الافتراضية',
          );
          final defaultLocation = _getDefaultLocation(language);
          return LocationModel(
            method: location.method,
            latitude: location.latitude,
            longitude: location.longitude,
            city: defaultLocation['city']!,
            country: defaultLocation['country']!,
            timezone: _getTimezoneForCountry(defaultLocation['country']!),
            timestamp: location.timestamp,
          );
        }

        return location;
      } else {
        throw Exception('Location permission not granted');
      }
    } catch (e) {
      print('⚠️ فشل جلب الموقع، استخدام القيم الافتراضية: $e');
      final defaultLocation = _getDefaultLocation(language);
      return LocationModel(
        method: LocationMethod.manual,
        latitude: null,
        longitude: null,
        city: defaultLocation['city']!,
        country: defaultLocation['country']!,
        timezone: _getTimezoneForCountry(defaultLocation['country']!),
        timestamp: DateTime.now(),
      );
    }
  }

  // دالة مساعدة للحصول على المدينة الافتراضية للبلد
  String _getDefaultCity(String country) {
    final cityMap = {
      'السعودية': 'الرياض',
      'مصر': 'القاهرة',
      'الجزائر': 'الجزائر',
      'المغرب': 'الرباط',
      'الإمارات': 'دبي',
      'الكويت': 'الكويت',
      'قطر': 'الدوحة',
      'عمان': 'مسقط',
      'البحرين': 'المنامة',
      'الأردن': 'عمان',
      'لبنان': 'بيروت',
      'تونس': 'تونس',
      'السودان': 'الخرطوم',
      'العراق': 'بغداد',
      'اليمن': 'صنعاء',
    };

    return cityMap[country] ?? 'الرياض';
  }

  // دالة مساعدة للحصول على timezone للبلد
  String _getTimezoneForCountry(String country) {
    final timezoneMap = {
      'السعودية': 'Asia/Riyadh',
      'مصر': 'Africa/Cairo',
      'الجزائر': 'Africa/Algiers',
      'المغرب': 'Africa/Casablanca',
      'الإمارات': 'Asia/Dubai',
      'الكويت': 'Asia/Kuwait',
      'قطر': 'Asia/Qatar',
      'عمان': 'Asia/Muscat',
      'البحرين': 'Asia/Bahrain',
      'الأردن': 'Asia/Amman',
      'لبنان': 'Asia/Beirut',
      'تونس': 'Africa/Tunis',
      'السودان': 'Africa/Khartoum',
      'العراق': 'Asia/Baghdad',
      'اليمن': 'Asia/Aden',
    };

    return timezoneMap[country] ?? 'Asia/Riyadh';
  }

  // دالة مساعدة للحصول على الموقع الافتراضي بناءً على اللغة
  Map<String, String> _getDefaultLocation(String language) {
    switch (language) {
      case 'ar':
        return {'country': 'السعودية', 'city': 'الرياض'};
      case 'en':
        return {'country': 'United States', 'city': 'New York'};
      case 'fr':
        return {'country': 'France', 'city': 'Paris'};
      case 'id':
        return {'country': 'Indonesia', 'city': 'Jakarta'};
      case 'ur':
        return {'country': 'Pakistan', 'city': 'Karachi'};
      case 'tr':
        return {'country': 'Turkey', 'city': 'Istanbul'};
      case 'bn':
        return {'country': 'Bangladesh', 'city': 'Dhaka'};
      case 'ms':
        return {'country': 'Malaysia', 'city': 'Kuala Lumpur'};
      case 'fa':
        return {'country': 'Iran', 'city': 'Tehran'};
      case 'es':
        return {'country': 'Spain', 'city': 'Madrid'};
      case 'de':
        return {'country': 'Germany', 'city': 'Berlin'};
      case 'zh':
        return {'country': 'China', 'city': 'Beijing'};
      default:
        return {'country': 'السعودية', 'city': 'الرياض'};
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await _firebaseService.sendEmailVerification();
  }

  @override
  Future<void> signOut() async {
    await _firebaseService.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseService.currentUser;
    if (user == null) return null;

    try {
      final userData = await _firebaseService.getDocument('users', user.uid);
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  @override
  bool isEmailVerified() {
    return _firebaseService.currentUser?.emailVerified ?? false;
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseService.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final userDoc = await _firebaseService.getDocument('users', user.uid);
      return UserModel.fromJson(userDoc);
    });
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found for that email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'email-already-in-use':
        return Exception('The account already exists for that email.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'operation-not-allowed':
        return Exception('Email/password accounts are not enabled.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'too-many-requests':
        return Exception('Too many sign-in attempts. Please try again later.');
      default:
        return Exception('An error occurred: ${e.message}');
    }
  }

  Future<void> _saveDeviceToken(String uid) async {
    try {
      final messaging = FirebaseMessaging.instance;

      // طلب الإذن لاستقبال الإشعارات (مرة واحدة فقط عند أول تشغيل)
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('⚠️ المستخدم رفض الإشعارات');
        return;
      }

      // الحصول على التوكن
      final token = await messaging.getToken();

      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'deviceToken': token,
        });
        print('✅ تم حفظ deviceToken بنجاح: $token');
      } else {
        print('⚠️ لم يتم الحصول على FCM token');
      }
    } catch (e) {
      print('❌ خطأ أثناء حفظ الـ deviceToken: $e');
    }
  }

  @override
  Future<void> updateUserLanguage(String language) async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }

      await _firebaseService.updateDocument('users', user.uid, {
        'language': language,
      });

      print('✅ تم تحديث اللغة بنجاح إلى: $language');
    } catch (e) {
      print('❌ خطأ أثناء تحديث اللغة: $e');
      throw Exception('فشل تحديث اللغة: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      // تنظيف البريد الإلكتروني من المسافات
      final cleanEmail = email.trim().toLowerCase();

      print('🔄 محاولة إرسال رابط إعادة تعيين كلمة المرور إلى: $cleanEmail');

      await FirebaseAuth.instance.sendPasswordResetEmail(email: cleanEmail);

      print('✅ تم إرسال رابط إعادة تعيين كلمة المرور بنجاح إلى: $cleanEmail');
      print('📧 تحقق من صندوق الوارد أو مجلد Spam في بريدك الإلكتروني');
    } on FirebaseAuthException catch (e) {
      print('❌ خطأ Firebase أثناء إرسال رابط إعادة تعيين كلمة المرور:');
      print('   - الكود: ${e.code}');
      print('   - الرسالة: ${e.message}');

      // معالجة أخطاء محددة
      if (e.code == 'user-not-found') {
        throw Exception('لا يوجد حساب مسجل بهذا البريد الإلكتروني');
      } else if (e.code == 'invalid-email') {
        throw Exception('البريد الإلكتروني غير صالح');
      } else if (e.code == 'too-many-requests') {
        throw Exception('تم إرسال عدد كبير من الطلبات. يرجى المحاولة لاحقاً');
      }

      throw _handleAuthException(e);
    } catch (e) {
      print('❌ خطأ غير متوقع: $e');
      throw Exception('فشل إرسال رابط إعادة تعيين كلمة المرور: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }

      final uid = user.uid;

      print('🔄 جاري حذف البيانات من Firestore...');
      // حذف بيانات المستخدم من Firestore
      await _firebaseService.deleteDocument('users', uid);
      print('✅ تم حذف بيانات المستخدم من Firestore');

      print('🔄 جاري حذف الحساب من Firebase Auth...');
      // حذف حساب المستخدم من Firebase Auth
      await user.delete();
      print('✅ تم حذف الحساب من Firebase Auth بنجاح');
    } on FirebaseAuthException catch (e) {
      print('❌ خطأ Firebase أثناء حذف الحساب:');
      print('   - الكود: ${e.code}');
      print('   - الرسالة: ${e.message}');

      if (e.code == 'requires-recent-login') {
        throw Exception('يجب تسجيل الدخول مرة أخرى قبل حذف الحساب');
      }

      throw _handleAuthException(e);
    } catch (e) {
      print('❌ خطأ غير متوقع أثناء حذف الحساب: $e');
      throw Exception('فشل حذف الحساب: $e');
    }
  }
}
