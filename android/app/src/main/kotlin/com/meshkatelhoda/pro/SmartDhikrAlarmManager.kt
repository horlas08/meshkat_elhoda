package com.meshkatelhoda.pro

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * AlarmManager scheduler for Smart Dhikr (Smart Voice Azkar).
 * Uses setAlarmClock for maximum reliability on OEM devices when app is killed.
 */
class SmartDhikrAlarmManager(private val context: Context) {

    companion object {
        private const val TAG = "SmartDhikrAlarmManager"
        private const val BASE_REQUEST_CODE = 7000
    }

    private val alarmManager: AlarmManager by lazy {
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    }

    fun scheduleSmartDhikrAlarm(
        alarmId: Int,
        triggerTimeMillis: Long
    ) {
        val intent = Intent(context, SmartDhikrBroadcastReceiver::class.java).apply {
            action = SmartDhikrBroadcastReceiver.ACTION_PLAY_SMART_DHIKR
            putExtra(SmartDhikrBroadcastReceiver.EXTRA_ALARM_ID, alarmId)
        }

        val requestCode = BASE_REQUEST_CODE + alarmId
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

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
                Log.d(TAG, "✅ Scheduled Smart Dhikr alarm with setAlarmClock: id=$alarmId time=$triggerTimeMillis requestCode=$requestCode")
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
                Log.d(TAG, "✅ Scheduled Smart Dhikr alarm with setExact: id=$alarmId requestCode=$requestCode")
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "⚠️ SecurityException scheduling Smart Dhikr alarm - trying setExactAndAllowWhileIdle", e)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTimeMillis,
                        pendingIntent
                    )
                    Log.d(TAG, "📌 Smart Dhikr scheduled with setExactAndAllowWhileIdle")
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
                    Log.d(TAG, "📌 Smart Dhikr scheduled with setExact (pre-M)")
                }
            } catch (e2: Exception) {
                Log.e(TAG, "❌ All exact Smart Dhikr methods failed, using setAndAllowWhileIdle", e2)
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
                Log.w(TAG, "⚠️ Fallback: Scheduled inexact Smart Dhikr alarm")
            }
        }
    }

    fun cancelSmartDhikrAlarm(alarmId: Int) {
        val intent = Intent(context, SmartDhikrBroadcastReceiver::class.java).apply {
            action = SmartDhikrBroadcastReceiver.ACTION_PLAY_SMART_DHIKR
        }

        val requestCode = BASE_REQUEST_CODE + alarmId
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.cancel(pendingIntent)
        Log.d(TAG, "Cancelled Smart Dhikr alarm: id=$alarmId")
    }
}
