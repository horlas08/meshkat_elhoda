package com.meshkatelhoda.pro

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import java.util.Calendar

/**
 * Helper class for scheduling Athan alarms using AlarmManager.
 * AlarmManager works reliably even when app is terminated.
 * Uses setAlarmClock for most reliable delivery on all Android versions.
 */
class AthanAlarmManager(private val context: Context) {
    
    companion object {
        private const val TAG = "AthanAlarmManager"
        private const val BASE_REQUEST_CODE = 5000
        private const val REMINDER_BASE_REQUEST_CODE = 6000
    }
    
    private val alarmManager: AlarmManager by lazy {
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    }
    
    /**
     * Check if we can schedule exact alarms (Android 12+)
     */
    fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
    }
    
    /**
     * Schedules an Athan alarm for a specific prayer time.
     * 
     * @param prayerId Unique ID for this prayer notification
     * @param triggerTimeMillis The time to trigger the alarm (Unix timestamp in millis)
     * @param muezzinId The ID of the selected muezzin
     * @param isFajr Whether this is Fajr prayer
     * @param prayerName The name of the prayer
     * @param title Notification title
     * @param body Notification body
     */
    fun scheduleAthanAlarm(
        prayerId: Int,
        triggerTimeMillis: Long,
        muezzinId: String,
        isFajr: Boolean,
        prayerName: String,
        title: String,
        body: String
    ) {
        val intent = Intent(context, AthanBroadcastReceiver::class.java).apply {
            action = AthanBroadcastReceiver.ACTION_PLAY_ATHAN
            putExtra(AthanBroadcastReceiver.EXTRA_MUEZZIN_ID, muezzinId)
            putExtra(AthanBroadcastReceiver.EXTRA_IS_FAJR, isFajr)
            putExtra(AthanBroadcastReceiver.EXTRA_PRAYER_NAME, prayerName)
            putExtra(AthanBroadcastReceiver.EXTRA_TITLE, title)
            putExtra(AthanBroadcastReceiver.EXTRA_BODY, body)
        }
        
        val requestCode = BASE_REQUEST_CODE + prayerId
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // IMPORTANT: AlarmClockInfo requires a "show intent" (usually an Activity).
        // Some OEMs behave poorly if this is not an Activity PendingIntent.
        val showIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        val showPendingIntent = PendingIntent.getActivity(
            context,
            requestCode,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        try {
            // Use setAlarmClock for most reliable delivery (appears in status bar)
            // This works on all Android versions and is the most reliable method
            // CRITICAL: setAlarmClock wakes the device even from Doze mode
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val alarmInfo = AlarmManager.AlarmClockInfo(triggerTimeMillis, showPendingIntent)
                alarmManager.setAlarmClock(alarmInfo, pendingIntent)
                Log.d(TAG, "✅ Scheduled Athan alarm with setAlarmClock: prayerId=$prayerId, time=$triggerTimeMillis, requestCode=$requestCode")
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
                Log.d(TAG, "✅ Scheduled Athan alarm with setExact: prayerId=$prayerId, requestCode=$requestCode")
            }
        } catch (e: SecurityException) {
            // This can happen on Android 12+ if SCHEDULE_EXACT_ALARM is revoked
            Log.e(TAG, "⚠️ SecurityException scheduling alarm - trying setExactAndAllowWhileIdle", e)
            
            try {
                // Try setExactAndAllowWhileIdle (works even in Doze mode on Android 6+)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP, 
                        triggerTimeMillis, 
                        pendingIntent
                    )
                    Log.d(TAG, "📌 Scheduled with setExactAndAllowWhileIdle")
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
                    Log.d(TAG, "📌 Scheduled with setExact (pre-M)")
                }
            } catch (e2: Exception) {
                Log.e(TAG, "❌ All exact alarm methods failed, using setAndAllowWhileIdle", e2)
                
                // Final fallback to inexact alarm (will be delayed up to a few minutes)
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, 
                    triggerTimeMillis, 
                    pendingIntent
                )
                Log.w(TAG, "⚠️ Fallback: Scheduled inexact alarm")
            }
        }
    }
    
    /**
     * Cancels a scheduled Athan alarm.
     */
    fun cancelAthanAlarm(prayerId: Int) {
        val intent = Intent(context, AthanBroadcastReceiver::class.java).apply {
            action = AthanBroadcastReceiver.ACTION_PLAY_ATHAN
        }
        
        val requestCode = BASE_REQUEST_CODE + prayerId
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        alarmManager.cancel(pendingIntent)
        Log.d(TAG, "Cancelled Athan alarm: prayerId=$prayerId")
    }
    
    /**
     * Cancels all Athan alarms (for prayers 1-10).
     */
    fun cancelAllAthanAlarms() {
        for (i in 1..10) {
            cancelAthanAlarm(i)
        }
        Log.d(TAG, "Cancelled all Athan alarms")
    }

    /**
     * Schedule a pre-Athan reminder alarm (e.g., 5 minutes before prayer).
     * This triggers PreAthanReminderReceiver to show a notification.
     */
    fun schedulePreAthanReminderAlarm(
        reminderId: Int,
        triggerTimeMillis: Long,
        title: String,
        body: String
    ) {
        val intent = Intent(context, PreAthanReminderReceiver::class.java).apply {
            action = PreAthanReminderReceiver.ACTION_PRE_ATHAN_REMINDER
            putExtra(PreAthanReminderReceiver.EXTRA_TITLE, title)
            putExtra(PreAthanReminderReceiver.EXTRA_BODY, body)
            putExtra(PreAthanReminderReceiver.EXTRA_NOTIFICATION_ID, reminderId)
        }

        val requestCode = REMINDER_BASE_REQUEST_CODE + reminderId
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // AlarmClockInfo "show intent" should be an Activity PendingIntent.
        val showIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        val showPendingIntent = PendingIntent.getActivity(
            context,
            requestCode,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val alarmInfo = AlarmManager.AlarmClockInfo(triggerTimeMillis, showPendingIntent)
                alarmManager.setAlarmClock(alarmInfo, pendingIntent)
                Log.d(TAG, "✅ Scheduled Pre-Athan reminder with setAlarmClock: id=$reminderId, time=$triggerTimeMillis, requestCode=$requestCode")
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
                Log.d(TAG, "✅ Scheduled Pre-Athan reminder with setExact: id=$reminderId, requestCode=$requestCode")
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "⚠️ SecurityException scheduling reminder - trying setExactAndAllowWhileIdle", e)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTimeMillis,
                        pendingIntent
                    )
                    Log.d(TAG, "📌 Reminder scheduled with setExactAndAllowWhileIdle")
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
                    Log.d(TAG, "📌 Reminder scheduled with setExact (pre-M)")
                }
            } catch (e2: Exception) {
                Log.e(TAG, "❌ All exact reminder methods failed, using setAndAllowWhileIdle", e2)
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
                Log.w(TAG, "⚠️ Fallback: Scheduled inexact reminder")
            }
        }
    }

    /** Cancel a pre-Athan reminder alarm. */
    fun cancelPreAthanReminderAlarm(reminderId: Int) {
        val intent = Intent(context, PreAthanReminderReceiver::class.java).apply {
            action = PreAthanReminderReceiver.ACTION_PRE_ATHAN_REMINDER
        }

        val requestCode = REMINDER_BASE_REQUEST_CODE + reminderId
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
        Log.d(TAG, "Cancelled Pre-Athan reminder alarm: id=$reminderId")
    }
}
