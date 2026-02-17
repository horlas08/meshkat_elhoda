package com.meshkatelhoda.pro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log

class RamadanReminderReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "RamadanReceiver"
        const val ACTION_PLAY_RAMADAN_REMINDER = "com.meshkatelhoda.pro.PLAY_RAMADAN_REMINDER"
        const val EXTRA_TYPE = "type"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"

        @Volatile
        var wakeLock: PowerManager.WakeLock? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_PLAY_RAMADAN_REMINDER) return

        acquireWakeLock(context)

        val type = intent.getStringExtra(EXTRA_TYPE) ?: RamadanReminderAlarmManager.TYPE_SUHOOR
        val title = intent.getStringExtra(EXTRA_TITLE) ?: ""
        val body = intent.getStringExtra(EXTRA_BODY) ?: ""

        val serviceIntent = Intent(context, RamadanReminderForegroundService::class.java).apply {
            putExtra(RamadanReminderForegroundService.EXTRA_TYPE, type)
            putExtra(RamadanReminderForegroundService.EXTRA_TITLE, title)
            putExtra(RamadanReminderForegroundService.EXTRA_BODY, body)
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            Log.d(TAG, "Started RamadanReminderForegroundService: type=$type")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start RamadanReminderForegroundService", e)
            releaseWakeLock()
        }
    }

    private fun acquireWakeLock(context: Context) {
        try {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            releaseWakeLock()
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                "meshkat_elhoda:RamadanReminderWakeLock"
            ).apply {
                acquire(2 * 60 * 1000L)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to acquire wake lock", e)
        }
    }

    private fun releaseWakeLock() {
        try {
            wakeLock?.let {
                if (it.isHeld) it.release()
            }
        } catch (_: Exception) {
        } finally {
            wakeLock = null
        }
    }
}
