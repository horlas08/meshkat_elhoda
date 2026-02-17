package com.meshkatelhoda.pro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log

/**
 * BroadcastReceiver for Smart Dhikr scheduled by AlarmManager.
 * Starts SmartDhikrForegroundService so audio plays reliably after app kill.
 */
class SmartDhikrBroadcastReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "SmartDhikrReceiver"
        const val ACTION_PLAY_SMART_DHIKR = "com.meshkatelhoda.pro.PLAY_SMART_DHIKR"
        const val EXTRA_ALARM_ID = "alarm_id"

        @Volatile
        var wakeLock: PowerManager.WakeLock? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "🔔 Received broadcast: ${intent.action}")

        if (intent.action == ACTION_PLAY_SMART_DHIKR) {
            acquireWakeLock(context)

            val alarmId = intent.getIntExtra(EXTRA_ALARM_ID, 1)
            Log.d(TAG, "🔊 Starting SmartDhikrForegroundService: alarmId=$alarmId")

            val serviceIntent = Intent(context, SmartDhikrForegroundService::class.java).apply {
                putExtra(SmartDhikrForegroundService.EXTRA_ALARM_ID, alarmId)
            }

            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                Log.d(TAG, "✅ SmartDhikrForegroundService started")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Failed to start SmartDhikrForegroundService", e)
                releaseWakeLock()
            }
        }
    }

    private fun acquireWakeLock(context: Context) {
        try {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            releaseWakeLock()

            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                "meshkat_elhoda:SmartDhikrBroadcastWakeLock"
            ).apply {
                acquire(2 * 60 * 1000L)
            }

            Log.d(TAG, "🔒 WakeLock acquired in SmartDhikrBroadcastReceiver")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to acquire WakeLock", e)
        }
    }

    private fun releaseWakeLock() {
        try {
            wakeLock?.let {
                if (it.isHeld) {
                    it.release()
                    Log.d(TAG, "🔓 WakeLock released in SmartDhikrBroadcastReceiver")
                }
            }
            wakeLock = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error releasing WakeLock", e)
        }
    }
}
