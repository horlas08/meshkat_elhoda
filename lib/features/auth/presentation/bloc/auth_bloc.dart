import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meshkat_elhoda/core/services/prayer_notification_service_new.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/settings/data/models/notification_settings_model.dart';
import 'package:meshkat_elhoda/features/auth/domain/usecases/register_as_guest.dart';
import 'package:meshkat_elhoda/features/auth/domain/usecases/reset_password.dart';
import 'package:meshkat_elhoda/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:meshkat_elhoda/features/auth/domain/usecases/sign_up_with_email_and_password.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_event.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_state.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailAndPassword signInWithEmailAndPassword;
  final SignUpWithEmailAndPassword signUpWithEmailAndPassword;
  final RegisterAsGuest registerAsGuest;
  final ResetPassword resetPassword;
  late StreamSubscription? _authSubscription;

  AuthBloc({
    required this.signInWithEmailAndPassword,
    required this.signUpWithEmailAndPassword,
    required this.registerAsGuest,
    required this.resetPassword,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
    on<RegisterAsGuestRequested>(_onRegisterAsGuestRequested);
    on<UpdateLanguageRequested>(_onUpdateLanguageRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await signInWithEmailAndPassword.repository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    log('[AuthBloc] SignInRequested received. email=${event.email}, passLen=${event.password.length}');
    emit(SignInLoading());
    try {
      log('[AuthBloc] Calling signInWithEmailAndPassword...');
      final result = await signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      log('[AuthBloc] signInWithEmailAndPassword returned, folding result...');

      await result.fold(
        (failure) async {
          log('[AuthBloc] Sign-in failed: ${failure.message}');
          emit(AuthError(failure.message));
          log('[AuthBloc] Emitted AuthError');
        },
        (user) async {
          log('[AuthBloc] Sign-in success. userId=${user.uid}');

          // إطلاق حالة Authenticated فوراً لتجنب تعليق واجهة المستخدم
          emit(Authenticated(user));
          log('[AuthBloc] Emitted Authenticated');

          // ✅ حفظ لغة المستخدم من Firebase إلى SharedPreferences (غير حاجب)
          Future(() async {
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', user.language);
              log('✅ تم حفظ لغة المستخدم: ${user.language}');
            } catch (e) {
              log('⚠️ خطأ في حفظ اللغة: $e');
            }
          });
        },
      );
    } catch (e) {
      log('[AuthBloc] SignInRequested error: $e');
      if (!emit.isDone) {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(SignUpLoading());
    try {
      final result = await signUpWithEmailAndPassword(
        name: event.name,
        email: event.email,
        password: event.password,
        language: event.language,
        country: event.country,
      );

      await result.fold((failure) async => emit(AuthError(failure.message)), (
        user,
      ) async {
        // ✅ حفظ لغة المستخدم من Firebase إلى SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('language', user.language);
          log('✅ تم حفظ لغة المستخدم: ${user.language}');
        } catch (e) {
          log('⚠️ خطأ في حفظ اللغة: $e');
        }

        // إنشاء الحساب مباشرة بدون تحقق من البريد
        if (!emit.isDone) {
          emit(Authenticated(user));
        }
      });
    } catch (e) {
      if (!emit.isDone) {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await signInWithEmailAndPassword.repository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendEmailVerificationRequested(
    SendEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await signInWithEmailAndPassword.repository.sendEmailVerification();
      emit(EmailVerificationSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRegisterAsGuestRequested(
    RegisterAsGuestRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(GuestSignInLoading());
    try {
      final result = await registerAsGuest();
      result.fold((failure) => emit(AuthError(failure.message)), (user) {
        emit(Authenticated(user));
        emit(AuthSuccess('تم تسجيل الدخول كضيف بنجاح', isGuest: true));
      });
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onUpdateLanguageRequested(
    UpdateLanguageRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // تحديث اللغة في Firebase
      await signInWithEmailAndPassword.repository.updateUserLanguage(
        event.language,
      );

      // ✅ تحديث اللغة فيSharedPreferences لتطبيقها على الإشعارات فوراً
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language', event.language);
        log('✅ تم تحديث لغة الإشعارات: ${event.language}');

        // ✅ إعادة جدولة الإشعارات باللغة الجديدة
        final lat = prefs.getDouble('latitude');
        final lng = prefs.getDouble('longitude');

        if (lat != null && lng != null) {
          // تحميل إعدادات الإشعارات
          final settingsJson = prefs.getString('NOTIFICATION_SETTINGS');
          final settings = settingsJson != null
              ? NotificationSettingsModel.fromJson(settingsJson)
              : const NotificationSettingsModel();

          // إعادة جدولة الإشعارات باللغة الجديدة
          await PrayerNotificationService().scheduleTodayPrayers(
            latitude: lat,
            longitude: lng,
            language: event.language,
            settings: settings,
          );
          log('✅ تمت إعادة جدولة الإشعارات باللغة الجديدة');
        }
      } catch (e) {
        log('⚠️ خطأ في تحديث لغة SharedPreferences: $e');
      }

      // الحصول على بيانات المستخدم المحدثة
      final updatedUser = await signInWithEmailAndPassword.repository
          .getCurrentUser();

      if (updatedUser != null) {
        emit(Authenticated(updatedUser));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ResetPasswordLoading());
    try {
      final result = await resetPassword(event.email);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) => emit(
          PasswordResetEmailSent(
            AppLocalizations.of(event.context)!.checkSpamMessage,
          ),
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await signInWithEmailAndPassword.repository.deleteAccount();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
