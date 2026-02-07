package com.meshkatelhoda.pro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log

/**
 * BroadcastReceiver that handles Athan notifications when app is terminated.
 * This is triggered by AlarmManager scheduled alarms.
 * Uses ForegroundService for reliable playback on Android 14+.
 * 
 * CRITICAL: Acquires a WakeLock to ensure device wakes up even when screen is off.
 */
class AthanBroadcastReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "AthanBroadcastReceiver"
        const val ACTION_PLAY_ATHAN = "com.meshkatelhoda.pro.PLAY_ATHAN"
        const val EXTRA_MUEZZIN_ID = "muezzin_id"
        const val EXTRA_IS_FAJR = "is_fajr"
        const val EXTRA_PRAYER_NAME = "prayer_name"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        
        // Static WakeLock to be released by the service
        @Volatile
        var wakeLock: PowerManager.WakeLock? = null
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "🔔 Received broadcast: ${intent.action}")
        
        if (intent.action == ACTION_PLAY_ATHAN) {
            // ✅ CRITICAL: Acquire WakeLock IMMEDIATELY to prevent device from sleeping
            // This is essential when the screen is off
            acquireWakeLock(context)
            
            val muezzinId = intent.getStringExtra(EXTRA_MUEZZIN_ID) ?: "ali_almula"
            val isFajr = intent.getBooleanExtra(EXTRA_IS_FAJR, false)
            val prayerName = intent.getStringExtra(EXTRA_PRAYER_NAME) ?: "Prayer"
            val title = intent.getStringExtra(EXTRA_TITLE) ?: "حان وقت الصلاة"
            val body = intent.getStringExtra(EXTRA_BODY) ?: "حان الآن موعد صلاة $prayerName"
            
            Log.d(TAG, "🕌 Starting Athan ForegroundService: muezzin=$muezzinId, isFajr=$isFajr, prayer=$prayerName")
            
            // On Android 14+, we MUST use a ForegroundService for reliable audio playback
            // when the app is in background or terminated
            val serviceIntent = Intent(context, AthanForegroundService::class.java).apply {
                putExtra(AthanForegroundService.EXTRA_MUEZZIN_ID, muezzinId)
                putExtra(AthanForegroundService.EXTRA_IS_FAJR, isFajr)
                putExtra(AthanForegroundService.EXTRA_PRAYER_NAME, prayerName)
                putExtra(AthanForegroundService.EXTRA_TITLE, title)
                putExtra(AthanForegroundService.EXTRA_BODY, body)
            }
            
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                Log.d(TAG, "✅ AthanForegroundService started successfully")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Failed to start AthanForegroundService", e)
                // Release WakeLock since service failed
                releaseWakeLock()
                
                // Fallback to notification-based approach
                val athanService = AthanNotificationService(context)
                athanService.showAthanNotification(
                    muezzinId = muezzinId,
                    isFajr = isFajr,
                    prayerName = prayerName,
                    title = title,
                    body = body
                )
            }
        }
    }
    
    /**
     * Acquire a WakeLock to keep the CPU running while we start the service.
     * This is CRITICAL for screen-off scenarios.
     */
    private fun acquireWakeLock(context: Context) {
        try {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            
            // Release any existing WakeLock first
            releaseWakeLock()
            
            // Acquire a new PARTIAL_WAKE_LOCK (keeps CPU running)
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                "meshkat_elhoda:AthanBroadcastWakeLock"
            ).apply {
                // Set timeout to prevent indefinite lock (2 minutes max)
                acquire(2 * 60 * 1000L)
            }
            
            Log.d(TAG, "🔒 WakeLock acquired in BroadcastReceiver")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to acquire WakeLock", e)
        }
    }
    
    /**
     * Release the WakeLock if held.
     * Called when service fails to start or by the service when done.
     */
    private fun releaseWakeLock() {
        try {
            wakeLock?.let {
                if (it.isHeld) {
                    it.release()
                    Log.d(TAG, "🔓 WakeLock released in BroadcastReceiver")
                }
            }
            wakeLock = null
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error releasing WakeLock", e)
        }
    }
}
