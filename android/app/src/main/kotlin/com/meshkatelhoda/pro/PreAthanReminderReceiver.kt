package com.meshkatelhoda.pro

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * BroadcastReceiver for pre-Athan reminders (5 minutes before prayer).
 * Triggered by AlarmManager scheduled alarms.
 */
class PreAthanReminderReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "PreAthanReminder"
        private const val CHANNEL_ID = "pre_athan_reminder_channel"

        const val ACTION_PRE_ATHAN_REMINDER = "com.meshkatelhoda.pro.PRE_ATHAN_REMINDER"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val EXTRA_NOTIFICATION_ID = "notification_id"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_PRE_ATHAN_REMINDER) return

        val title = intent.getStringExtra(EXTRA_TITLE) ?: "⏳ Prayer Approaching"
        val body = intent.getStringExtra(EXTRA_BODY) ?: "5 minutes remaining"
        val notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, 91001)

        Log.d(TAG, "🔔 Showing pre-athan reminder: id=$notificationId")

        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            ensureChannel(context, nm)

            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_REMINDER)
                .setAutoCancel(true)
                .build()

            nm.notify(notificationId, notification)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error showing pre-athan reminder", e)
        }
    }

    private fun ensureChannel(context: Context, nm: NotificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val existing = nm.getNotificationChannel(CHANNEL_ID)
            if (existing != null) return

            val channel = NotificationChannel(
                CHANNEL_ID,
                "تذكير قبل الأذان",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "تنبيه قبل موعد الصلاة"
                enableVibration(true)
            }

            nm.createNotificationChannel(channel)
        }
    }
}
