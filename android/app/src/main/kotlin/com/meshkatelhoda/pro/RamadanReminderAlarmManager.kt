package com.meshkatelhoda.pro

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class RamadanReminderAlarmManager(private val context: Context) {

    companion object {
        private const val TAG = "RamadanAlarmManager"
        private const val BASE_REQUEST_CODE = 8000
        const val TYPE_SUHOOR = "suhoor"
        const val TYPE_IFTAR = "iftar"
    }

    private val alarmManager: AlarmManager by lazy {
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    }

    fun scheduleReminder(type: String, triggerTimeMillis: Long, title: String, body: String) {
        val intent = Intent(context, RamadanReminderReceiver::class.java).apply {
            action = RamadanReminderReceiver.ACTION_PLAY_RAMADAN_REMINDER
            putExtra(RamadanReminderReceiver.EXTRA_TYPE, type)
            putExtra(RamadanReminderReceiver.EXTRA_TITLE, title)
            putExtra(RamadanReminderReceiver.EXTRA_BODY, body)
        }

        val requestCode = BASE_REQUEST_CODE + if (type == TYPE_IFTAR) 2 else 1
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
                Log.d(TAG, "Scheduled Ramadan reminder with setAlarmClock: type=$type time=$triggerTimeMillis")
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
                Log.d(TAG, "Scheduled Ramadan reminder with setExact: type=$type time=$triggerTimeMillis")
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException scheduling Ramadan reminder - trying fallbacks", e)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTimeMillis,
                        pendingIntent
                    )
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
                }
            } catch (e2: Exception) {
                Log.e(TAG, "All exact Ramadan methods failed, using inexact", e2)
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
            }
        }
    }

    fun cancelReminder(type: String) {
        val intent = Intent(context, RamadanReminderReceiver::class.java).apply {
            action = RamadanReminderReceiver.ACTION_PLAY_RAMADAN_REMINDER
        }
        val requestCode = BASE_REQUEST_CODE + if (type == TYPE_IFTAR) 2 else 1
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
        Log.d(TAG, "Cancelled Ramadan reminder: type=$type")
    }
}
