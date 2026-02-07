// The Cloud Functions for Firebase SDK
const { logger } = require("firebase-functions");
const { onRequest } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const axios = require("axios");

initializeApp();

// ========================================
// 🛠️ Helper: تنظيف البيانات قبل الحفظ
// ========================================
function cleanData(obj) {
  const result = {};
  for (const key in obj) {
    if (obj[key] === undefined) {
      result[key] = null;
    } else {
      result[key] = obj[key];
    }
  }
  return result;
}

// ========================================
// 📅 جدولة يومية - إرسال إشعارات الصلاة
// ========================================
exports.scheduleDailyPrayerNotifications = onSchedule({
  schedule: "0 */6 * * *", // كل 6 ساعات للتأكد من تغطية كل المناطق الزمنية
  timeZone: "UTC",
}, async (event) => {
  logger.info("🕌 بدء جدولة إشعارات الصلاة اليومية");
  
  try {
    const db = getFirestore();
    
    // جلب كل المستخدمين الذين فعّلوا الإشعارات
    const usersSnapshot = await db.collection("users")
      .where("notificationsEnabled", "==", true)
      .get();

    if (usersSnapshot.empty) {
      logger.info("⚠️ لا يوجد مستخدمين مفعلين للإشعارات");
      return null;
    }

    let totalScheduled = 0;

    for (const userDoc of usersSnapshot.docs) {
      const userData = cleanData(userDoc.data());
      const deviceToken = userData.deviceToken || userData.fcmToken;
      const latitude = userData.location?.latitude || 30.5853431;
      const longitude = userData.location?.longitude || 31.5035127;
      const language = userData.language || "ar";
      const notificationSettings = userData.notificationSettings || {};

      if (!deviceToken) {
        logger.warn(`⚠️ المستخدم ${userDoc.id} ليس لديه Device Token`);
        continue;
      }

      // ✅ جلب مواقيت الصلاة مع الـ timezone من الـ API مباشرة
      const prayerData = await fetchPrayerTimesWithTimezone(latitude, longitude);
      
      if (prayerData && prayerData.timings && prayerData.timezone) {
        const prayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
        
        for (const prayer of prayers) {
          const prayerTime = prayerData.timings[prayer];
          const minutesBefore = notificationSettings[prayer] || 5;
          
          if (prayerTime) {
            const notification = createPrayerNotification(
              prayer,
              prayerTime,
              language,
              minutesBefore
            );
            
            // ✅ استخدام timezone من الـ API فقط
            const scheduled = await scheduleNotificationWithTimezone(
              deviceToken,
              notification,
              prayerTime,
              prayer,
              minutesBefore,
              userDoc.id,
              prayerData.timezone // ✅ من الـ API مباشرة
            );
            
            if (scheduled) {
              totalScheduled++;
            }
          }
        }
      }
    }

    logger.info(`✅ تم جدولة ${totalScheduled} إشعار بنجاح`);
    return null;
    
  } catch (error) {
    logger.error("❌ خطأ في جدولة الإشعارات:", error);
    return null;
  }
});

// ========================================
// 🔔 إرسال الإشعارات المجدولة (كل دقيقة)
// ========================================
exports.sendScheduledNotifications = onSchedule({
  schedule: "* * * * *",
  timeZone: "UTC",
}, async (event) => {
  logger.info("🔔 فحص الإشعارات المجدولة...");
  
  try {
    const db = getFirestore();
    const messaging = getMessaging();
    const now = new Date();
    
    const snapshot = await db.collection("scheduledNotifications")
      .where("sent", "==", false)
      .get();

    if (snapshot.empty) {
      logger.info("⚠️ لا توجد إشعارات مجدولة");
      return null;
    }

    const promises = [];
    let sentCount = 0;
    let deletedCount = 0;

    for (const doc of snapshot.docs) {
      const data = cleanData(doc.data());
      
      const scheduledTime = data.scheduledTimestamp.toDate();
      const diff = now - scheduledTime;
      
      if (diff >= 0 && diff <= (2 * 60 * 1000)) {
        const message = {
          token: data.deviceToken,
          notification: {
            title: data.notification.title,
            body: data.notification.body,
          },
          data: {
            prayer: data.prayer || "",
            actualPrayerTime: data.actualPrayerTime || "",
            notificationTime: data.scheduledTimeString || "",
            minutesBefore: String(data.minutesBefore || 0),
            timezone: data.timezone || "UTC",
            type: "prayer_reminder",
          },
          android: {
            priority: "high",
            notification: {
              channelId: "prayer_channel",
              sound: "default",
              priority: "high",
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        };

        promises.push(
          messaging.send(message)
            .then(() => {
              sentCount++;
              logger.info(`✅ إرسال ${data.prayer}: ${data.notification.title}`);
              logger.info(`   📍 للمستخدم: ${data.userId || 'غير محدد'}`);
              logger.info(`   🌍 المنطقة الزمنية من API: ${data.timezone}`);
              logger.info(`   ⏰ الأذان: ${data.actualPrayerTime} | التنبيه: ${data.scheduledTimeString} (قبل ${data.minutesBefore} دقيقة)`);
              return doc.ref.update({ 
                sent: true, 
                sentAt: now 
              });
            })
            .catch((error) => {
              logger.error(`❌ فشل إرسال ${data.prayer}: ${error.message}`);
              return doc.ref.delete();
            })
        );
      } 
      else if (diff > (10 * 60 * 1000)) {
        deletedCount++;
        logger.warn(`⚠️ حذف إشعار قديم: ${data.prayer} - ${data.notification.title}`);
        promises.push(doc.ref.delete());
      }
    }

    await Promise.all(promises);
    
    if (sentCount > 0 || deletedCount > 0) {
      logger.info(`📊 النتيجة: ${sentCount} تم إرسالها | ${deletedCount} تم حذفها`);
    }
    
    return null;
    
  } catch (error) {
    logger.error("❌ خطأ في إرسال الإشعارات المجدولة:", error);
    return null;
  }
});

// ========================================
// 🌐 HTTP Endpoint - إرسال إشعار فوري
// ========================================
exports.sendPrayerNotification = onRequest(async (req, res) => {
  try {
    const { userId, prayer, language = "ar" } = req.body;

    if (!userId || !prayer) {
      res.status(400).json({ error: "userId و prayer مطلوبين" });
      return;
    }

    const db = getFirestore();
    const userDoc = await db.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      res.status(404).json({ error: "المستخدم غير موجود" });
      return;
    }

    const userData = cleanData(userDoc.data());
    const deviceToken = userData.deviceToken || userData.fcmToken;

    if (!deviceToken) {
      res.status(400).json({ error: "المستخدم ليس لديه Device Token" });
      return;
    }

    const latitude = userData.location?.latitude || 30.5853431;
    const longitude = userData.location?.longitude || 31.5035127;
    const notificationSettings = userData.notificationSettings || {};
    const minutesBefore = notificationSettings[prayer] || 5;

    // ✅ جلب الـ timezone من الـ API
    const prayerData = await fetchPrayerTimesWithTimezone(latitude, longitude);

    if (!prayerData || !prayerData.timings[prayer]) {
      res.status(404).json({ error: "لم يتم العثور على وقت الصلاة" });
      return;
    }

    const notification = createPrayerNotification(
      prayer,
      prayerData.timings[prayer],
      language,
      minutesBefore
    );

    const messaging = getMessaging();
    const message = {
      token: deviceToken,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: {
        prayer: prayer,
        actualPrayerTime: prayerData.timings[prayer],
        minutesBefore: String(minutesBefore),
        timezone: prayerData.timezone, // ✅ من الـ API
        type: "prayer_reminder",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "prayer_channel",
          sound: "default",
          priority: "high",
        },
      },
    };

    const response = await messaging.send(message);
    
    logger.info(`✅ تم إرسال إشعار ${prayer} للمستخدم ${userId}`);
    
    res.json({
      success: true,
      messageId: response,
      prayer: prayer,
      actualPrayerTime: prayerData.timings[prayer],
      timezone: prayerData.timezone,
      minutesBefore: minutesBefore,
    });
    
  } catch (error) {
    logger.error("❌ خطأ في إرسال الإشعار:", error);
    res.status(500).json({ error: error.message });
  }
});

// ========================================
// 🌐 HTTP Endpoint - تحديث Device Token
// ========================================
exports.updateDeviceToken = onRequest(async (req, res) => {
  try {
    const { userId, deviceToken } = req.body;

    if (!userId || !deviceToken) {
      res.status(400).json({ error: "userId و deviceToken مطلوبين" });
      return;
    }

    const db = getFirestore();
    await db.collection("users").doc(userId).update(cleanData({
      deviceToken: deviceToken,
      fcmToken: deviceToken,
      fcmTokenUpdatedAt: new Date(),
    }));

    logger.info(`✅ تم تحديث Device Token للمستخدم ${userId}`);
    
    res.json({
      success: true,
      message: "تم تحديث Token بنجاح"
    });
    
  } catch (error) {
    logger.error("❌ خطأ في تحديث Token:", error);
    res.status(500).json({ error: error.message });
  }
});

// ========================================
// 🌐 HTTP Endpoint - تحديث إعدادات التنبيه
// ========================================
exports.updateNotificationSettings = onRequest(async (req, res) => {
  try {
    const { userId, notificationSettings } = req.body;

    if (!userId || !notificationSettings) {
      res.status(400).json({ error: "userId و notificationSettings مطلوبين" });
      return;
    }

    const prayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
    for (const prayer of prayers) {
      const value = notificationSettings[prayer];
      if (value !== undefined && (value < 0 || value > 30)) {
        res.status(400).json({ 
          error: `قيمة ${prayer} يجب أن تكون بين 0 و 30 دقيقة` 
        });
        return;
      }
    }

    const db = getFirestore();
    await db.collection("users").doc(userId).update(cleanData({
      notificationSettings: notificationSettings,
      settingsUpdatedAt: new Date(),
    }));

    logger.info(`✅ تم تحديث إعدادات التنبيه للمستخدم ${userId}`);
    logger.info(`   إعدادات: ${JSON.stringify(notificationSettings)}`);
    
    res.json({
      success: true,
      message: "تم تحديث إعدادات التنبيه بنجاح",
      notificationSettings: notificationSettings,
    });
    
  } catch (error) {
    logger.error("❌ خطأ في تحديث الإعدادات:", error);
    res.status(500).json({ error: error.message });
  }
});

// ========================================
// 🛠️ Helper Functions
// ========================================

// ✅ جلب المواقيت مع الـ timezone من الـ API مباشرة
async function fetchPrayerTimesWithTimezone(latitude, longitude) {
  try {
    const today = new Date();
    const dateStr = `${today.getDate()}-${today.getMonth() + 1}-${today.getFullYear()}`;
    
    const url = `http://api.aladhan.com/v1/timings/${dateStr}?latitude=${latitude}&longitude=${longitude}&method=5`;
    
    logger.info(`🌐 طلب API للإحداثيات: ${latitude}, ${longitude}`);
    
    const response = await axios.get(url);
    
    if (response.data && response.data.data) {
      const data = response.data.data;
      const timezone = data.meta.timezone; // ✅ الـ timezone من الـ API
      
      logger.info(`✅ تم جلب المواقيت - المنطقة الزمنية من API: ${timezone}`);
      
      return {
        timings: {
          Fajr: data.timings.Fajr,
          Dhuhr: data.timings.Dhuhr,
          Asr: data.timings.Asr,
          Maghrib: data.timings.Maghrib,
          Isha: data.timings.Isha,
        },
        timezone: timezone, // ✅ من API فقط
        date: data.date.gregorian,
      };
    }
    return null;
    
  } catch (error) {
    logger.error("❌ خطأ في جلب مواقيت الصلاة:", error);
    return null;
  }
}

function createPrayerNotification(prayer, actualPrayerTime, language, minutesBefore) {
  const translations = {
    ar: {
      Fajr: {
        title: "⏰ تنبيه صلاة الفجر",
        body: `باقي ${minutesBefore} دقيقة على صلاة الفجر - الأذان ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ تنبيه صلاة الظهر",
        body: `باقي ${minutesBefore} دقيقة على صلاة الظهر - الأذان ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ تنبيه صلاة العصر",
        body: `باقي ${minutesBefore} دقيقة على صلاة العصر - الأذان ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ تنبيه صلاة المغرب",
        body: `باقي ${minutesBefore} دقيقة على صلاة المغرب - الأذان ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ تنبيه صلاة العشاء",
        body: `باقي ${minutesBefore} دقيقة على صلاة العشاء - الأذان ${actualPrayerTime}`
      },
    },
    en: {
      Fajr: {
        title: "⏰ Fajr Prayer Reminder",
        body: `${minutesBefore} minutes until Fajr prayer - Adhan at ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ Dhuhr Prayer Reminder",
        body: `${minutesBefore} minutes until Dhuhr prayer - Adhan at ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ Asr Prayer Reminder",
        body: `${minutesBefore} minutes until Asr prayer - Adhan at ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ Maghrib Prayer Reminder",
        body: `${minutesBefore} minutes until Maghrib prayer - Adhan at ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ Isha Prayer Reminder",
        body: `${minutesBefore} minutes until Isha prayer - Adhan at ${actualPrayerTime}`
      },
    },
    fr: {
      Fajr: {
        title: "⏰ Rappel Prière Fajr",
        body: `${minutesBefore} minutes avant la prière de Fajr - Adhan à ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ Rappel Prière Dhuhr",
        body: `${minutesBefore} minutes avant la prière de Dhuhr - Adhan à ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ Rappel Prière Asr",
        body: `${minutesBefore} minutes avant la prière de Asr - Adhan à ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ Rappel Prière Maghrib",
        body: `${minutesBefore} minutes avant la prière de Maghrib - Adhan à ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ Rappel Prière Isha",
        body: `${minutesBefore} minutes avant la prière de Isha - Adhan à ${actualPrayerTime}`
      },
    },
    id: {
      Fajr: {
        title: "⏰ Pengingat Sholat Subuh",
        body: `${minutesBefore} menit lagi menuju Sholat Subuh - Adzan pukul ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ Pengingat Sholat Dzuhur",
        body: `${minutesBefore} menit lagi menuju Sholat Dzuhur - Adzan pukul ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ Pengingat Sholat Ashar",
        body: `${minutesBefore} menit lagi menuju Sholat Ashar - Adzan pukul ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ Pengingat Sholat Maghrib",
        body: `${minutesBefore} menit lagi menuju Sholat Maghrib - Adzan pukul ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ Pengingat Sholat Isya",
        body: `${minutesBefore} menit lagi menuju Sholat Isya - Adzan pukul ${actualPrayerTime}`
      },
    },
    ur: {
      Fajr: {
        title: "⏰ نماز فجر کی یاد دہانی",
        body: `نماز فجر میں ${minutesBefore} منٹ باقی - اذان ${actualPrayerTime} بجے`
      },
      Dhuhr: {
        title: "⏰ نماز ظہر کی یاد دہانی",
        body: `نماز ظہر میں ${minutesBefore} منٹ باقی - اذان ${actualPrayerTime} بجے`
      },
      Asr: {
        title: "⏰ نماز عصر کی یاد دہانی",
        body: `نماز عصر میں ${minutesBefore} منٹ باقی - اذان ${actualPrayerTime} بجے`
      },
      Maghrib: {
        title: "⏰ نماز مغرب کی یاد دہانی",
        body: `نماز مغرب میں ${minutesBefore} منٹ باقی - اذان ${actualPrayerTime} بجے`
      },
      Isha: {
        title: "⏰ نماز عشاء کی یاد دہانی",
        body: `نماز عشاء میں ${minutesBefore} منٹ باقی - اذان ${actualPrayerTime} بجے`
      },
    },
    tr: {
      Fajr: {
        title: "⏰ Sabah Namazı Hatırlatıcı",
        body: `Sabah namazına ${minutesBefore} dakika kaldı - Ezan ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ Öğle Namazı Hatırlatıcı",
        body: `Öğle namazına ${minutesBefore} dakika kaldı - Ezan ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ İkindi Namazı Hatırlatıcı",
        body: `İkindi namazına ${minutesBefore} dakika kaldı - Ezan ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ Akşam Namazı Hatırlatıcı",
        body: `Akşam namazına ${minutesBefore} dakika kaldı - Ezan ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ Yatsı Namazı Hatırlatıcı",
        body: `Yatsı namazına ${minutesBefore} dakika kaldı - Ezan ${actualPrayerTime}`
      },
    },
    bn: {
      Fajr: {
        title: "⏰ ফজরের নামাজের রিমাইন্ডার",
        body: `ফজরের নামাজে ${minutesBefore} মিনিট বাকি - আযান ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ যোহরের নামাজের রিমাইন্ডার",
        body: `যোহরের নামাজে ${minutesBefore} মিনিট বাকি - আযান ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ আসরের নামাজের রিমাইন্ডার",
        body: `আসরের নামাজে ${minutesBefore} মিনিট বাকি - আযান ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ মাগরিবের নামাজের রিমাইন্ডার",
        body: `মাগরিবের নামাজে ${minutesBefore} মিনিট বাকি - আযান ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ এশার নামাজের রিমাইন্ডার",
        body: `এশার নামাজে ${minutesBefore} মিনিট বাকি - আযান ${actualPrayerTime}`
      },
    },
    ms: {
      Fajr: {
        title: "⏰ Peringatan Solat Subuh",
        body: `${minutesBefore} minit lagi ke Solat Subuh - Azan pada ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ Peringatan Solat Zohor",
        body: `${minutesBefore} minit lagi ke Solat Zohor - Azan pada ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ Peringatan Solat Asar",
        body: `${minutesBefore} minit lagi ke Solat Asar - Azan pada ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ Peringatan Solat Maghrib",
        body: `${minutesBefore} minit lagi ke Solat Maghrib - Azan pada ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ Peringatan Solat Isyak",
        body: `${minutesBefore} minit lagi ke Solat Isyak - Azan pada ${actualPrayerTime}`
      },
    },
    fa: {
      Fajr: {
        title: "⏰ یادآوری نماز صبح",
        body: `${minutesBefore} دقیقه تا نماز صبح - اذان ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ یادآوری نماز ظهر",
        body: `${minutesBefore} دقیقه تا نماز ظهر - اذان ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ یادآوری نماز عصر",
        body: `${minutesBefore} دقیقه تا نماز عصر - اذان ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ یادآوری نماز مغرب",
        body: `${minutesBefore} دقیقه تا نماز مغرب - اذان ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ یادآوری نماز عشا",
        body: `${minutesBefore} دقیقه تا نماز عشا - اذان ${actualPrayerTime}`
      },
    },
    es: {
      Fajr: {
        title: "⏰ Recordatorio Oración Fajr",
        body: `${minutesBefore} minutos para la oración de Fajr - Adhan a las ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ Recordatorio Oración Dhuhr",
        body: `${minutesBefore} minutos para la oración de Dhuhr - Adhan a las ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ Recordatorio Oración Asr",
        body: `${minutesBefore} minutos para la oración de Asr - Adhan a las ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ Recordatorio Oración Maghrib",
        body: `${minutesBefore} minutos para la oración de Maghrib - Adhan a las ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ Recordatorio Oración Isha",
        body: `${minutesBefore} minutos para la oración de Isha - Adhan a las ${actualPrayerTime}`
      },
    },
    de: {
      Fajr: {
        title: "⏰ Fajr-Gebet Erinnerung",
        body: `${minutesBefore} Minuten bis zum Fajr-Gebet - Adhan um ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ Dhuhr-Gebet Erinnerung",
        body: `${minutesBefore} Minuten bis zum Dhuhr-Gebet - Adhan um ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ Asr-Gebet Erinnerung",
        body: `${minutesBefore} Minuten bis zum Asr-Gebet - Adhan um ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ Maghrib-Gebet Erinnerung",
        body: `${minutesBefore} Minuten bis zum Maghrib-Gebet - Adhan um ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ Isha-Gebet Erinnerung",
        body: `${minutesBefore} Minuten bis zum Isha-Gebet - Adhan um ${actualPrayerTime}`
      },
    },
    zh: {
      Fajr: {
        title: "⏰ 晨礼提醒",
        body: `距离晨礼还有 ${minutesBefore} 分钟 - 宣礼时间 ${actualPrayerTime}`
      },
      Dhuhr: {
        title: "⏰ 晌礼提醒",
        body: `距离晌礼还有 ${minutesBefore} 分钟 - 宣礼时间 ${actualPrayerTime}`
      },
      Asr: {
        title: "⏰ 晡礼提醒",
        body: `距离晡礼还有 ${minutesBefore} 分钟 - 宣礼时间 ${actualPrayerTime}`
      },
      Maghrib: {
        title: "⏰ 昏礼提醒",
        body: `距离昏礼还有 ${minutesBefore} 分钟 - 宣礼时间 ${actualPrayerTime}`
      },
      Isha: {
        title: "⏰ 宵礼提醒",
        body: `距离宵礼还有 ${minutesBefore} 分钟 - 宣礼时间 ${actualPrayerTime}`
      },
    },
  };

  const langData = translations[language] || translations["ar"];
  return langData[prayer] || { 
    title: "Prayer Reminder", 
    body: `${minutesBefore} minutes until prayer - ${actualPrayerTime}` 
  };
}

// ✅ جدولة الإشعارات باستخدام timezone من API فقط
async function scheduleNotificationWithTimezone(
  deviceToken, 
  notification, 
  actualPrayerTimeString, 
  prayer, 
  minutesBefore, 
  userId,
  timezone // ✅ من API الأذان فقط
) {
  try {
    // تحويل وقت الصلاة من string إلى Date object
    const [hours, minutes] = actualPrayerTimeString.split(":").map(Number);
    
    // ✅ حساب offset المنطقة الزمنية من UTC
    const timezoneOffset = getTimezoneOffset(timezone);
    
    logger.info(`📅 جدولة ${prayer} للمستخدم ${userId}`);
    logger.info(`   🌍 المنطقة الزمنية من API: ${timezone} (Offset: ${timezoneOffset} دقيقة)`);
    
    // إنشاء Date object بتوقيت المنطقة المحلية
    const now = new Date();
    const localPrayerTime = new Date(now);
    localPrayerTime.setHours(hours, minutes, 0, 0);
    
    // تحويل لـ UTC
    const utcPrayerTime = new Date(localPrayerTime.getTime() - (timezoneOffset * 60 * 1000));
    
    // وقت إرسال التنبيه (قبل الأذان بـ X دقيقة)
    const notificationTime = new Date(utcPrayerTime);
    notificationTime.setMinutes(notificationTime.getMinutes() - minutesBefore);
    
    // لو الوقت فات النهاردة، اجدوله بكرة
    const currentUtc = new Date();
    if (notificationTime < currentUtc) {
      notificationTime.setDate(notificationTime.getDate() + 1);
      utcPrayerTime.setDate(utcPrayerTime.getDate() + 1);
      logger.info(`   ⏭️ الوقت فات، تم الجدولة لليوم التالي`);
    }
    
    const notificationTimeString = `${String(notificationTime.getUTCHours()).padStart(2, '0')}:${String(notificationTime.getUTCMinutes()).padStart(2, '0')}`;
    
    logger.info(`   ⏰ الأذان: ${actualPrayerTimeString} (بتوقيت ${timezone})`);
    logger.info(`   🔔 التنبيه: ${notificationTimeString} UTC (قبل ${minutesBefore} دقيقة)`);
    
    const db = getFirestore();
    
    await db.collection("scheduledNotifications").add(cleanData({
      deviceToken: deviceToken,
      userId: userId,
      notification: notification,
      prayer: prayer,
      scheduledTimestamp: notificationTime, // ✅ UTC time
      scheduledTimeString: notificationTimeString,
      actualPrayerTime: actualPrayerTimeString,
      minutesBefore: minutesBefore,
      timezone: timezone, // ✅ من API الأذان فقط
      timezoneOffset: timezoneOffset, // حفظ الـ offset للمرجع
      createdAt: new Date(),
      sent: false,
    }));
    
    return true;
    
  } catch (error) {
    logger.error(`❌ خطأ في جدولة تنبيه ${prayer}:`, error);
    return false;
  }
}

// ✅ حساب offset المنطقة الزمنية من UTC (بالدقائق)
function getTimezoneOffset(timezone) {
  try {
    // قائمة شاملة بالمناطق الزمنية وoffset-ها
    const timezoneOffsets = {
      // أفريقيا
      "Africa/Cairo": 120,
      "Africa/Algiers": 60,
      "Africa/Lagos": 60,
      "Africa/Johannesburg": 120,
      "Africa/Nairobi": 180,
      "Africa/Casablanca": 60,
      "Africa/Tunis": 60,
      "Africa/Tripoli": 120,
      "Africa/Khartoum": 120,
      "Africa/Addis_Ababa": 180,
      
      // الشرق الأوسط
      "Asia/Dubai": 240,
      "Asia/Riyadh": 180,
      "Asia/Kuwait": 180,
      "Asia/Baghdad": 180,
      "Asia/Tehran": 210,
      "Asia/Muscat": 240,
      "Asia/Qatar": 180,
      "Asia/Bahrain": 180,
      "Asia/Aden": 180,
      "Asia/Damascus": 180,
      "Asia/Beirut": 180,
      "Asia/Amman": 180,
      "Asia/Jerusalem": 180,
      
      // آسيا
      "Asia/Karachi": 300,
      "Asia/Kabul": 270,
      "Asia/Dhaka": 360,
      "Asia/Kolkata": 330,
      "Asia/Jakarta": 420,
      "Asia/Singapore": 480,
      "Asia/Kuala_Lumpur": 480,
      "Asia/Shanghai": 480,
      "Asia/Tokyo": 540,
      "Asia/Seoul": 540,
      "Asia/Manila": 480,
      "Asia/Bangkok": 420,
      "Asia/Ho_Chi_Minh": 420,
      "Asia/Istanbul": 180,
      "Asia/Tashkent": 300,
      "Asia/Almaty": 360,
      
      // أوروبا
      "Europe/London": 0,
      "Europe/Paris": 60,
      "Europe/Berlin": 60,
      "Europe/Madrid": 60,
      "Europe/Rome": 60,
      "Europe/Amsterdam": 60,
      "Europe/Brussels": 60,
      "Europe/Vienna": 60,
      "Europe/Stockholm": 60,
      "Europe/Moscow": 180,
      "Europe/Athens": 120,
      "Europe/Istanbul": 180,
      
      // أمريكا الشمالية
      "America/New_York": -300,
      "America/Chicago": -360,
      "America/Denver": -420,
      "America/Los_Angeles": -480,
      "America/Toronto": -300,
      "America/Vancouver": -480,
      "America/Mexico_City": -360,
      
      // أمريكا الجنوبية
      "America/Sao_Paulo": -180,
      "America/Buenos_Aires": -180,
      "America/Lima": -300,
      "America/Bogota": -300,
      
      // أستراليا والمحيط الهادئ
      "Australia/Sydney": 600,
      "Australia/Melbourne": 600,
      "Australia/Perth": 480,
      "Pacific/Auckland": 720,
      "Pacific/Fiji": 720,
    };
    
    const offset = timezoneOffsets[timezone];
    
    if (offset !== undefined) {
      logger.info(`✅ تم العثور على offset للمنطقة ${timezone}: ${offset} دقيقة`);
      return offset;
    } else {
      logger.warn(`⚠️ لم يتم العثور على ${timezone} في القائمة، استخدام UTC`);
      return 0;
    }
    
  } catch (error) {
    logger.error(`❌ خطأ في حساب timezone offset:`, error);
    return 0;
  }
}

// ========================================
// 🧹 تنظيف الإشعارات القديمة (يومياً)
// ========================================
exports.cleanupOldNotifications = onSchedule({
  schedule: "0 1 * * *",
  timeZone: "UTC",
}, async (event) => {
  logger.info("🧹 بدء تنظيف الإشعارات القديمة");
  
  try {
    const db = getFirestore();
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    
    const snapshot = await db.collection("scheduledNotifications")
      .where("createdAt", "<", yesterday)
      .get();
    
    if (snapshot.empty) {
      logger.info("⚠️ لا توجد إشعارات قديمة للحذف");
      return null;
    }
    
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    
    logger.info(`✅ تم حذف ${snapshot.size} إشعار قديم`);
    return null;
    
  } catch (error) {
    logger.error("❌ خطأ في تنظيف الإشعارات:", error);
    return null;
  }
});