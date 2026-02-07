import 'dart:developer';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:meshkat_elhoda/features/collective_khatma/domain/entities/collective_khatma_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meshkat_elhoda/features/collective_khatma/data/models/collective_khatma_model.dart';
import 'package:meshkat_elhoda/features/settings/data/models/notification_settings_model.dart';
import 'package:meshkat_elhoda/core/services/khushoo_mode_service.dart';

class CollectiveKhatmaNotificationService {
  static final CollectiveKhatmaNotificationService _instance =
      CollectiveKhatmaNotificationService._internal();

  factory CollectiveKhatmaNotificationService() => _instance;

  CollectiveKhatmaNotificationService._internal();

  static const String channelKey = 'collective_khatma_channel';
  static const String channelName = 'Collective Khatma';
  static const String channelDesc =
      'Collective Khatma and daily wird notifications';

  /// تهيئة القناة
  Future<void> initialize() async {
    try {
      await AwesomeNotifications().initialize(
        null, // Use default icon
        [
          NotificationChannel(
            channelKey: channelKey,
            channelName: channelName,
            channelDescription: channelDesc,
            defaultColor: const Color(0xFFD4CF37), // Golden color
            importance: NotificationImportance.High,
            playSound: true,
            enableVibration: true,
          ),
        ],
      );
      log('✅ تم تهيئة قناة إشعارات الختمات الجماعية');
    } catch (e) {
      log('❌ خطأ في تهيئة إشعارات الختمات: $e');
    }
  }

  /// فحص وإرسال التنبيهات بناءً على حالة الختمات
  Future<void> checkAndSendNotifications({
    required List<CollectiveKhatmaEntity> khatmas,
    required String currentUserId,
    String language = 'ar',
  }) async {
    final prefs = await SharedPreferences.getInstance();

    for (final khatma in khatmas) {
      // 1. تنبيه اكتمال الختمة
      if (khatma.isComplete) {
        await _checkCompletionNotification(khatma, prefs, language);
      }

      // البحث عن أجزاء المستخدم في هذه الختمة
      final userParts = khatma.parts
          .where((p) => p.userId == currentUserId)
          .toList();

      for (final part in userParts) {
        final deadlineId =
            ('deadline'.hashCode + khatma.id.hashCode + part.partNumber).abs();
        final lateId = ('late'.hashCode + khatma.id.hashCode + part.partNumber)
            .abs();

        // إذا كان الجزء غير مقروء
        if (part.status == PartStatus.notRead) {
          // 2. تنبيه اقتراب الموعد النهائي
          await _checkDeadlineNotification(khatma, part, prefs, language);

          // 3. تنبيه التأخر عن الجزء (مثلاً إذا مر نصف الوقت)
          await _checkLateNotification(khatma, part, prefs, language);
        } else {
          // تم قراءة الجزء، نلغي التنبيهات
          await AwesomeNotifications().cancel(deadlineId);
          await AwesomeNotifications().cancel(lateId);
        }
      }
    }

    // 4. تنبيهات تشجيعية (بشكل عشوائي أو دوري)
    await _checkMotivationalNotification(prefs, language);
  }

  /// 1. إشعار اكتمال الختمة
  Future<void> _checkCompletionNotification(
    CollectiveKhatmaEntity khatma,
    SharedPreferences prefs,
    String language,
  ) async {
    final key = 'notified_completion_${khatma.id}';
    if (prefs.getBool(key) == true) return;

    final title = _getCompletionTitle(language);
    final body = _getCompletionBody(language, khatma.title);

    final sent = await _sendNotification(
      id: khatma.id.hashCode.abs(),
      title: title,
      body: body,
      language: language,
    );

    if (sent) {
      await prefs.setBool(key, true);
    }
  }

  /// 2. إشعار اقتراب الموعد النهائي (قبل 24 ساعة)
  Future<void> _checkDeadlineNotification(
    CollectiveKhatmaEntity khatma,
    KhatmaPartEntity part,
    SharedPreferences prefs,
    String language,
  ) async {
    final now = DateTime.now();
    final deadlineReminderTime = khatma.endDate.subtract(
      const Duration(hours: 24),
    );
    final id = ('deadline'.hashCode + khatma.id.hashCode + part.partNumber)
        .abs();

    if (deadlineReminderTime.isAfter(now)) {
      // إذا كان وقت التذكير في المستقبل، نقوم بجدولته
      final title = _getDeadlineTitle(language);
      final body = _getDeadlineBody(language, khatma.title, part.partNumber);

      await _sendNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: deadlineReminderTime,
        language: language,
      );
    } else if (khatma.endDate.isAfter(now)) {
      // إذا تجاوزنا وقت التذكير ولكن الختمة لم تنته بعد
      if (khatma.endDate.difference(now).inHours <= 24) {
        final key =
            'notified_deadline_${khatma.id}_${part.partNumber}_${now.day}';
        if (prefs.getBool(key) == true) return;

        final title = _getDeadlineTitle(language);
        final body = _getDeadlineBody(language, khatma.title, part.partNumber);

        final sent = await _sendNotification(
          id: id,
          title: title,
          body: body,
          language: language,
        );

        if (sent) {
          await prefs.setBool(key, true);
        }
      }
    }
  }

  /// 3. إشعار التأخر (إذا مر 75% من الوقت المخصص ولم يقرأ)
  Future<void> _checkLateNotification(
    CollectiveKhatmaEntity khatma,
    KhatmaPartEntity part,
    SharedPreferences prefs,
    String language,
  ) async {
    final now = DateTime.now();
    final totalDuration = khatma.endDate.difference(khatma.startDate);
    final reminderTime = khatma.startDate.add(
      Duration(minutes: (totalDuration.inMinutes * 0.75).round()),
    );
    final id = ('late'.hashCode + khatma.id.hashCode + part.partNumber).abs();

    if (reminderTime.isAfter(now)) {
      // جدولة التذكير للمستقبل
      final title = _getLateTitle(language);
      final body = _getLateBody(language, khatma.title, part.partNumber);

      await _sendNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: reminderTime,
        language: language,
      );
    } else if (khatma.endDate.isAfter(now)) {
      // إذا مر وقت التذكير، اعرضه فوراً إذا لم يعرض
      final key = 'notified_late_${khatma.id}_${part.partNumber}_${now.day}';
      if (prefs.getBool(key) == true) return;

      final title = _getLateTitle(language);
      final body = _getLateBody(language, khatma.title, part.partNumber);

      final sent = await _sendNotification(
        id: id,
        title: title,
        body: body,
        language: language,
      );

      if (sent) {
        await prefs.setBool(key, true);
      }
    }
  }

  /// يقوم بجلب البيانات الضرورية والتحقق من التنبيهات
  /// يمكن استدعاء هذه الدالة من main.dart أو background task
  Future<void> processBackgroundChecks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final firestore = FirebaseFirestore.instance;

      // ✅ جلب لغة المستخدم من Firebase (وليس من SharedPreferences)
      String language = 'ar'; // اللغة الافتراضية
      try {
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          language = userDoc.data()!['language'] as String? ?? 'ar';
          log('✅ تم جلب لغة المستخدم من Firebase: $language');
        }
      } catch (e) {
        log('⚠️ خطأ في جلب لغة المستخدم، استخدام اللغة الافتراضية: $e');
      }

      // جلب معرفات الختمات التي يشارك فيها المستخدم
      final userKhatmasSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('collective_khatmas')
          .get();

      final List<CollectiveKhatmaEntity> activeKhatmas = [];

      for (final doc in userKhatmasSnapshot.docs) {
        final khatmaId = doc.data()['khatmaId'] as String?;
        if (khatmaId != null) {
          final khatmaDoc = await firestore
              .collection('collective_khatmas')
              .doc(khatmaId)
              .get();

          if (khatmaDoc.exists) {
            final khatma = CollectiveKhatmaModel.fromFirestore(khatmaDoc);
            // فقط الختمات النشطة
            if (!khatma.isExpired) {
              activeKhatmas.add(khatma);
            }
          }
        }
      }

      if (activeKhatmas.isNotEmpty) {
        await checkAndSendNotifications(
          khatmas: activeKhatmas,
          currentUserId: user.uid,
          language: language, // ✅ استخدام اللغة من Firebase
        );
      }
    } catch (e) {
      log('❌ خطأ في معالجة تنبيهات الختمات في الخلفية: $e');
    }
  }

  /// 4. تنبيهات تشجيعية (يومية)
  Future<void> _checkMotivationalNotification(
    SharedPreferences prefs,
    String language,
  ) async {
    final now = DateTime.now();
    final lastMotivationStr = prefs.getString('last_motivation_date');

    // إرسال إشعار واحد يومياً كحد أقصى
    if (lastMotivationStr != null) {
      final lastDate = DateTime.parse(lastMotivationStr);
      if (lastDate.day == now.day &&
          lastDate.month == now.month &&
          lastDate.year == now.year) {
        return;
      }
    }

    final title = _getMotivationalTitle(language);
    final body = _getMotivationalBody(language);

    final sent = await _sendNotification(
      id: 99999, // ID ثابت للتشجيع اليومي ليتجدد
      title: title,
      body: body,
      language: language,
    );

    if (sent) {
      await prefs.setString('last_motivation_date', now.toIso8601String());
    }
  }

  /// إلغاء التنبيهات لجزء محدد (عند مغادرة الختمة مثلاً)
  Future<void> cancelNotificationsForPart({
    required String khatmaId,
    required int partNumber,
  }) async {
    final deadlineId = ('deadline'.hashCode + khatmaId.hashCode + partNumber)
        .abs();
    final lateId = ('late'.hashCode + khatmaId.hashCode + partNumber).abs();

    await AwesomeNotifications().cancel(deadlineId);
    await AwesomeNotifications().cancel(lateId);
    log('❌ تم إلغاء تنبيهات الجزء $partNumber من الختمة $khatmaId');
  }

  /// دالة مساعدة لإرسال أو جدولة الإشعار
  Future<bool> _sendNotification({
    required int id,
    required String title,
    required String body,
    DateTime? scheduledDate,
    String language = 'ar',
  }) async {
    // 1. التحقق من إعدادات الإشعارات
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('NOTIFICATION_SETTINGS');
    if (settingsJson != null) {
      final settings = NotificationSettingsModel.fromJson(settingsJson);
      if (!settings.isCollectiveKhatmaEnabled) {
        log('🔕 إشعارات الختمة الجماعية معطلة من الإعدادات');
        return false;
      }
    }

    // 2. التحقق من وضع الخشوع للإشعارات الفورية
    if (scheduledDate == null) {
      final isKhushoo = await KhushooModeService().isKhushooModeActive();
      if (isKhushoo) {
        log('🤫 تم منع الإشعار بسبب وضع الخشوع');
        return false;
      }
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
          title: title,
          body: body,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: scheduledDate != null
            ? NotificationCalendar.fromDate(date: scheduledDate)
            : null,
      );
      if (scheduledDate != null) {
        log('📅 تم جدولة إشعار: $title في $scheduledDate');
      } else {
        log('📢 تم إرسال إشعار فوري: $title');
      }
      return true;
    } catch (e) {
      log('❌ خطأ في إرسال الإشعار: $e');
      return false;
    }
  }

  // ========== دوال الترجمة ==========

  String _getCompletionTitle(String language) {
    switch (language) {
      case 'ar':
        return 'اكتملت الختمة! 🎉';
      case 'en':
        return 'Khatma Completed! 🎉';
      case 'fr':
        return 'Khatma Terminée! 🎉';
      case 'id':
        return 'Khatma Selesai! 🎉';
      case 'ur':
        return 'ختمہ مکمل ہوا! 🎉';
      case 'tr':
        return 'Hatme Tamamlandı! 🎉';
      case 'bn':
        return 'খতম সম্পন্ন হয়েছে! 🎉';
      case 'ms':
        return 'Khatam Selesai! 🎉';
      case 'fa':
        return 'ختم کامل شد! 🎉';
      case 'es':
        return '¡Khatma Completada! 🎉';
      case 'de':
        return 'Khatma Abgeschlossen! 🎉';
      case 'zh':
        return '诵经完成！🎉';
      default:
        return 'اكتملت الختمة! 🎉';
    }
  }

  String _getCompletionBody(String language, String khatmaTitle) {
    switch (language) {
      case 'ar':
        return 'مبارك! تم اكتمال ختمة "$khatmaTitle". تقبل الله صالح الأعمال.';
      case 'en':
        return 'Congratulations! Khatma "$khatmaTitle" has been completed. May Allah accept our good deeds.';
      case 'fr':
        return 'Félicitations! La khatma "$khatmaTitle" est terminée. Qu\'Allah accepte nos bonnes actions.';
      case 'id':
        return 'Selamat! Khatma "$khatmaTitle" telah selesai. Semoga Allah menerima amal baik kita.';
      case 'ur':
        return 'مبارک ہو! ختمہ "$khatmaTitle" مکمل ہو گیا ہے۔ اللہ ہماری نیک اعمال قبول فرمائے۔';
      case 'tr':
        return 'Tebrikler! "$khatmaTitle" hatmesi tamamlandı. Allah iyi amellerimizi kabul etsin.';
      case 'bn':
        return 'অভিনন্দন! "$khatmaTitle" খতম সম্পন্ন হয়েছে। আল্লাহ আমাদের ভাল কাজগুলো কবুল করুন।';
      case 'ms':
        return 'Tahniah! Khatam "$khatmaTitle" telah selesai. Semoga Allah menerima amal soleh kita.';
      case 'fa':
        return 'تبریک! ختم "$khatmaTitle" کامل شد. خداوند اعمال صالح ما را بپذیرد.';
      case 'es':
        return '¡Felicidades! La khatma "$khatmaTitle" ha sido completada. Que Alá acepte nuestras buenas acciones.';
      case 'de':
        return 'Glückwunsch! Die Khatma "$khatmaTitle" wurde abgeschlossen. Möge Allah unsere guten Taten annehmen.';
      case 'zh':
        return '恭喜！"$khatmaTitle"诵经已完成。愿安拉接受我们的善行。';
      default:
        return 'مبارك! تم اكتمال ختمة "$khatmaTitle". تقبل الله صالح الأعمال.';
    }
  }

  String _getDeadlineTitle(String language) {
    switch (language) {
      case 'ar':
        return 'تذكير بقرب انتهاء الختمة ⏳';
      case 'en':
        return 'Khatma Deadline Approaching ⏳';
      case 'fr':
        return 'Échéance de la Khatma Proche ⏳';
      case 'id':
        return 'Batas Waktu Khatma Mendekat ⏳';
      case 'ur':
        return 'ختمہ کی ڈیڈلائن قریب ہے ⏳';
      case 'tr':
        return 'Hatme Son Tarihi Yaklaşıyor ⏳';
      case 'bn':
        return 'খতমের সময়সীমা শেষ হচ্ছে ⏳';
      case 'ms':
        return 'Tarikh Akhir Khatam Menghampiri ⏳';
      case 'fa':
        return 'مهلت ختم نزدیک است ⏳';
      case 'es':
        return 'Plazo de Khatma Se Acerca ⏳';
      case 'de':
        return 'Khatma-Frist Nähert Sich ⏳';
      case 'zh':
        return '诵经截止时间临近 ⏳';
      default:
        return 'تذكير بقرب انتهاء الختمة ⏳';
    }
  }

  String _getDeadlineBody(String language, String khatmaTitle, int partNumber) {
    switch (language) {
      case 'ar':
        return 'تبقى أقل من 24 ساعة على انتهاء ختمة "$khatmaTitle". لا تنس قراءة الجزء $partNumber.';
      case 'en':
        return 'Less than 24 hours left for khatma "$khatmaTitle". Don\'t forget to read part $partNumber.';
      case 'fr':
        return 'Moins de 24 heures restent pour la khatma "$khatmaTitle". N\'oubliez pas de lire la partie $partNumber.';
      case 'id':
        return 'Kurang dari 24 jam tersisa untuk khatma "$khatmaTitle". Jangan lupa baca bagian $partNumber.';
      case 'ur':
        return 'ختمہ "$khatmaTitle" کے لیے 24 گھنٹے سے کم وقت باقی ہے۔ حصہ $partNumber پڑھنا نہ بھولیں۔';
      case 'tr':
        return '"$khatmaTitle" hatmesi için 24 saatten az kaldı. Bölüm $partNumber\'ı okumayı unutmayın.';
      case 'bn':
        return '"$khatmaTitle" খতমের জন্য ২৪ ঘন্টারও কম সময় বাকি আছে। অংশ $partNumber পড়তে ভুলবেন না।';
      case 'ms':
        return 'Kurang 24 jam lagi untuk khatam "$khatmaTitle". Jangan lupa baca bahagian $partNumber.';
      case 'fa':
        return 'کمتر از ۲۴ ساعت تا پایان ختم "$khatmaTitle" باقی مانده است. بخش $partNumber را فراموش نکنید.';
      case 'es':
        return 'Menos de 24 horas restan para la khatma "$khatmaTitle". No olvides leer la parte $partNumber.';
      case 'de':
        return 'Weniger als 24 Stunden verbleiben für die Khatma "$khatmaTitle". Vergessen Sie nicht, Teil $partNumber zu lesen.';
      case 'zh':
        return '"$khatmaTitle"诵经还剩不到24小时。别忘了阅读第$partNumber部分。';
      default:
        return 'تبقى أقل من 24 ساعة على انتهاء ختمة "$khatmaTitle". لا تنس قراءة الجزء $partNumber.';
    }
  }

  String _getLateTitle(String language) {
    switch (language) {
      case 'ar':
        return 'تذكير بالقراءة 📖';
      case 'en':
        return 'Reading Reminder 📖';
      case 'fr':
        return 'Rappel de Lecture 📖';
      case 'id':
        return 'Pengingat Membaca 📖';
      case 'ur':
        return 'پڑھنے کی یاددہانی 📖';
      case 'tr':
        return 'Okuma Hatırlatması 📖';
      case 'bn':
        return 'পাঠের অনুস্মারক 📖';
      case 'ms':
        return 'Peringatan Membaca 📖';
      case 'fa':
        return 'یادآوری مطالعه 📖';
      case 'es':
        return 'Recordatorio de Lectura 📖';
      case 'de':
        return 'Lese-Erinnerung 📖';
      case 'zh':
        return '阅读提醒 📖';
      default:
        return 'تذكير بالقراءة 📖';
    }
  }

  String _getLateBody(String language, String khatmaTitle, int partNumber) {
    switch (language) {
      case 'ar':
        return 'هل قرأت وردك اليوم؟ ختمة "$khatmaTitle" بانتظار إكمالك للجزء $partNumber.';
      case 'en':
        return 'Have you read your wird today? Khatma "$khatmaTitle" awaits your completion of part $partNumber.';
      case 'fr':
        return 'Avez-vous lu votre wird aujourd\'hui ? La khatma "$khatmaTitle" attend que vous terminiez la partie $partNumber.';
      case 'id':
        return 'Sudahkah Anda membaca wird hari ini? Khatma "$khatmaTitle" menunggu Anda menyelesaikan bagian $partNumber.';
      case 'ur':
        return 'کیا آپ نے آج اپنا ورد پڑھا ہے؟ ختمہ "$khatmaTitle" آپ کے حصہ $partNumber مکمل ہونے کا منتظر ہے۔';
      case 'tr':
        return 'Bugün wirdinizi okudunuz mu? "$khatmaTitle" hatmesi, $partNumber. bölümü tamamlamanızı bekliyor.';
      case 'bn':
        return 'আপনি কি আজ আপনার উইর্ড পড়েছেন? "$khatmaTitle" খতম আপনার অংশ $partNumber টি সম্পন্ন করার অপেক্ষায় আছে।';
      case 'ms':
        return 'Adakah anda sudah membaca wird hari ini? Khatam "$khatmaTitle" menunggu anda menyelesaikan bahagian $partNumber.';
      case 'fa':
        return 'آیا امروز ورد خود را خوانده‌اید؟ ختم "$khatmaTitle" منتظر تکمیل بخش $partNumber توسط شماست.';
      case 'es':
        return '¿Has leído tu wird hoy? La khatma "$khatmaTitle" espera que completes la parte $partNumber.';
      case 'de':
        return 'Haben Sie Ihr Wird heute gelesen? Die Khatma "$khatmaTitle" wartet auf Ihre Vervollständigung von Teil $partNumber.';
      case 'zh':
        return '您今天读过wird了吗？"$khatmaTitle"诵经正等待您完成第$partNumber部分。';
      default:
        return 'هل قرأت وردك اليوم؟ ختمة "$khatmaTitle" بانتظار إكمالك للجزء $partNumber.';
    }
  }

  String _getMotivationalTitle(String language) {
    switch (language) {
      case 'ar':
        return 'رسالة قرآنية 🌟';
      case 'en':
        return 'Quranic Message 🌟';
      case 'fr':
        return 'Message Coranique 🌟';
      case 'id':
        return 'Pesan Al-Quran 🌟';
      case 'ur':
        return 'قرآنی پیغام 🌟';
      case 'tr':
        return 'Kuran Mesajı 🌟';
      case 'bn':
        return 'কুরআনিক বার্তা 🌟';
      case 'ms':
        return 'Mesej Al-Quran 🌟';
      case 'fa':
        return 'پیام قرآنی 🌟';
      case 'es':
        return 'Mensaje Coránico 🌟';
      case 'de':
        return 'Koranische Botschaft 🌟';
      case 'zh':
        return '古兰经信息 🌟';
      default:
        return 'رسالة قرآنية 🌟';
    }
  }

  String _getMotivationalBody(String language) {
    // Note: Ideally, these should be picked from a larger localized list.
    // Simplifying to a generic message for now.
    switch (language) {
      case 'ar':
        return 'خيركم من تعلم القرآن وعلمه.';
      case 'en':
        return 'The best of you are those who learn the Quran and teach it.';
      case 'fr':
        return 'Le meilleur d\'entre vous est celui qui apprend le Coran et l\'enseigne.';
      case 'id':
        return 'Sebaik-baik kalian adalah orang yang belajar Al-Quran dan mengajarkannya.';
      case 'ur':
        return 'تم میں سے بہترین وہ ہے جو قرآن سیکھے اور سکھائے۔';
      case 'tr':
        return 'Sizin en hayırlınız Kuranı öğrenen ve öğretendir.';
      case 'bn':
        return 'তোমাদের মধ্যে সেই ব্যক্তি উত্তম যে কুরআন শিখে এবং শেখায়।';
      case 'ms':
        return 'Sebaik-baik kamu adalah orang yang belajar Al-Quran dan mengajarkannya.';
      case 'fa':
        return 'بهترین شما کسی است که قرآن را بیاموزد و آموزش دهد.';
      case 'es':
        return 'El mejor de vosotros es el que aprende el Corán y lo enseña.';
      case 'de':
        return 'Der Beste unter euch ist derjenige, der den Koran lernt und lehrt.';
      case 'zh':
        return '你们中最优秀的人是学习古兰经并教授它的人。';
      default:
        return 'خيركم من تعلم القرآن وعلمه.';
    }
  }
}
