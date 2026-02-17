package com.meshkatelhoda.pro

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import android.content.SharedPreferences

/**
 * Foreground Service for playing Athan audio reliably on Android 14+.
 * This ensures the audio continues playing even with aggressive app restrictions.
 * 
 * Users can stop the Athan by:
 * 1. Tapping the notification
 * 2. Tapping the "إيقاف الأذان" action button
 * 3. Swiping away the notification (on supported devices)
 */
class AthanForegroundService : Service() {

    companion object {
        private const val TAG = "AthanForegroundService"
        private const val NOTIFICATION_ID = 2001
        const val CHANNEL_ID = "athan_foreground_channel"

        private const val PREFS_NAME = "meshkat_athan"
        private const val PREF_KEY_STOP_LABEL = "athan_stop_label"
        private const val PREF_KEY_HIDE_LABEL = "athan_hide_label"
        private const val PREF_KEY_STOP_HINT = "athan_stop_hint"
        
        const val EXTRA_MUEZZIN_ID = "muezzin_id"
        const val EXTRA_IS_FAJR = "is_fajr"
        const val EXTRA_PRAYER_NAME = "prayer_name"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val ACTION_STOP = "com.meshkatelhoda.pro.STOP_ATHAN"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var screenWakeLock: PowerManager.WakeLock? = null
    private var stopReceiver: BroadcastReceiver? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🕌 Service created")
        createNotificationChannel()
        
        // Release BroadcastReceiver's WakeLock as we're now taking over
        releaseBroadcastReceiverWakeLock()
        
        // Acquire our own WakeLock
        acquireWakeLock()
        
        // ✅ Wake up the screen - this is CRITICAL for screen-off scenarios
        wakeUpScreen()
        
        registerStopReceiver()
    }
    
    /**
     * Release the WakeLock acquired by BroadcastReceiver.
     * The service now has its own WakeLock.
     */
    private fun releaseBroadcastReceiverWakeLock() {
        try {
            AthanBroadcastReceiver.wakeLock?.let {
                if (it.isHeld) {
                    it.release()
                    Log.d(TAG, "🔓 Released BroadcastReceiver WakeLock")
                }
            }
            AthanBroadcastReceiver.wakeLock = null
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing BroadcastReceiver WakeLock", e)
        }
    }
    
    /**
     * Wake up the screen so user can see the Athan notification.
     * This is essential for screen-off scenarios.
     * Uses multiple methods for maximum compatibility across Android versions.
     */
    @Suppress("DEPRECATION")
    private fun wakeUpScreen() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            
            // Check if screen is already on
            if (!powerManager.isInteractive) {
                Log.d(TAG, "📱 Screen is OFF - waking it up...")
                
                // Method 1: Use SCREEN_BRIGHT_WAKE_LOCK (works on most devices)
                screenWakeLock = powerManager.newWakeLock(
                    PowerManager.SCREEN_BRIGHT_WAKE_LOCK or 
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE,
                    "meshkat_elhoda:AthanScreenWakeLock"
                ).apply {
                    // Keep screen on for 30 seconds (enough to see the notification)
                    acquire(30 * 1000L)
                }
                
                // Method 2: Show notification over lockscreen
                // This ensures the notification is visible even when locked
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                        // On Android 8.1+, use setShowWhenLocked in the Activity
                        // For service, we rely on the notification's fullScreenIntent
                        Log.d(TAG, "📱 Using fullScreenIntent for lockscreen visibility")
                    } else {
                        // On older versions, we can use KeyguardManager
                        @Suppress("DEPRECATION")
                        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as android.app.KeyguardManager
                        Log.d(TAG, "📱 Keyguard locked: ${keyguardManager.isKeyguardLocked}")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error checking keyguard status", e)
                }
                
                Log.d(TAG, "✅ Screen wake lock acquired")
            } else {
                Log.d(TAG, "📱 Screen is already ON")
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to wake screen", e)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: action=${intent?.action}")
        
        if (intent?.action == ACTION_STOP) {
            Log.d(TAG, "Stop action received via Intent")
            stopAthan()
            return START_NOT_STICKY
        }

        val muezzinId = intent?.getStringExtra(EXTRA_MUEZZIN_ID) ?: "ali_almula"
        val isFajr = intent?.getBooleanExtra(EXTRA_IS_FAJR, false) ?: false
        val prayerName = intent?.getStringExtra(EXTRA_PRAYER_NAME) ?: "Prayer"
        val title = intent?.getStringExtra(EXTRA_TITLE) ?: "حان وقت الصلاة"
        val body = intent?.getStringExtra(EXTRA_BODY) ?: "حان الآن موعد صلاة $prayerName"

        // Start as foreground service immediately
        val notification = createNotification(title, body, prayerName)
        startForeground(NOTIFICATION_ID, notification)
        
        // Play the Athan audio
        playAthan(muezzinId, isFajr)

        return START_NOT_STICKY
    }

    private fun registerStopReceiver() {
        stopReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                Log.d(TAG, "Stop broadcast received")
                stopAthan()
            }
        }
        
        val filter = IntentFilter(ACTION_STOP)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(stopReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(stopReceiver, filter)
        }
    }

    private fun playAthan(muezzinId: String, isFajr: Boolean) {
        try {
            // Stop any existing player
            mediaPlayer?.release()
            
            val audioFileName = if (isFajr) "${muezzinId}_fajr" else "${muezzinId}_regular"
            val resId = resources.getIdentifier(audioFileName, "raw", packageName)
            
            if (resId == 0) {
                Log.e(TAG, "Audio resource not found: $audioFileName")
                stopSelf()
                return
            }
            
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .build()
                )
                setDataSource(applicationContext, Uri.parse("android.resource://$packageName/$resId"))
                prepare()
                setOnCompletionListener {
                    Log.d(TAG, "Athan playback completed")
                    // ✅ تفعيل وضع الخشوع عند انتهاء الأذان
                    activateKhushooMode()
                    stopAthan()
                }
                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error: what=$what, extra=$extra")
                    stopAthan()
                    true
                }
                start()
            }
            
            Log.d(TAG, "Started playing Athan: $audioFileName")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error playing Athan", e)
            stopAthan()
        }
    }
    
    /**
     * تفعيل وضع الخشوع - يكتم الإشعارات لمدة 30 دقيقة
     * ملاحظة: نستخدم نفس المفاتيح التي يستخدمها Flutter SharedPreferences
     * Flutter يضيف البادئة 'flutter.' تلقائياً عند القراءة من SharedPreferences
     */
    private fun activateKhushooMode() {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val endTime = System.currentTimeMillis() + (30 * 60 * 1000) // 30 دقيقة
            
            // تحويل الوقت لصيغة ISO8601 المتوافقة مع Dart DateTime.parse()
            val endTimeIso = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", java.util.Locale.US).apply {
                timeZone = java.util.TimeZone.getDefault()
            }.format(java.util.Date(endTime))
            
            prefs.edit().apply {
                // استخدام نفس أسماء المفاتيح التي يستخدمها Flutter
                // Flutter SharedPreferences يضيف 'flutter.' تلقائياً
                putString("flutter.khushoo_mode_end_time", endTimeIso)
                putBoolean("flutter.khushoo_mode_enabled", true)
                apply()
            }
            
            Log.d(TAG, "🤲 Khushoo Mode activated for 30 minutes, end time: $endTimeIso")
        } catch (e: Exception) {
            Log.e(TAG, "Error activating Khushoo Mode", e)
        }
    }

    private fun stopAthan() {
        Log.d(TAG, "Stopping Athan")
        try {
            mediaPlayer?.apply {
                if (isPlaying) stop()
                release()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping MediaPlayer", e)
        }
        mediaPlayer = null
        releaseWakeLock()
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "تشغيل الأذان",
                NotificationManager.IMPORTANCE_MAX // ✅ MAX importance for lockscreen visibility
            ).apply {
                description = "إشعار تشغيل الأذان - اضغط للإيقاف"
                setShowBadge(true)
                setSound(null, null) // No sound from notification itself
                enableVibration(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC // ✅ Show on lockscreen
                setBypassDnd(true) // ✅ Bypass Do Not Disturb mode
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(title: String, body: String, prayerName: String): Notification {
        // Intent to stop Athan when notification is clicked
        val stopIntent = Intent(this, AthanForegroundService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 
            NOTIFICATION_ID, 
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val stopLabel = prefs.getString(PREF_KEY_STOP_LABEL, "⏹️ إيقاف الأذان") ?: "⏹️ إيقاف الأذان"
        val hideLabel = prefs.getString(PREF_KEY_HIDE_LABEL, "✓ إخفاء") ?: "✓ إخفاء"
        val stopHint = prefs.getString(PREF_KEY_STOP_HINT, "🔇 اضغط هنا لإيقاف الأذان") ?: "🔇 اضغط هنا لإيقاف الأذان"

        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val overlayEnabled = flutterPrefs.getBoolean("flutter.isAthanOverlayEnabled", true)

        val fullScreenPendingIntent = if (overlayEnabled) {
            val overlayIntent = Intent(this, AthanAlarmActivity::class.java).apply {
                putExtra(AthanAlarmActivity.EXTRA_TITLE, title)
                putExtra(AthanAlarmActivity.EXTRA_BODY, body)
                putExtra(AthanAlarmActivity.EXTRA_PRAYER_NAME, prayerName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            PendingIntent.getActivity(
                this,
                NOTIFICATION_ID + 77,
                overlayIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else {
            stopPendingIntent
        }

        // Create a big text style to show the stop instructions prominently
        val bigTextStyle = NotificationCompat.BigTextStyle()
            .bigText("$body\n\n$stopHint")
            .setBigContentTitle(title)

        val contentPendingIntent = if (overlayEnabled) fullScreenPendingIntent else stopPendingIntent

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(bigTextStyle)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            // Clicking the notification opens overlay (if enabled) otherwise stops the Athan
            .setContentIntent(contentPendingIntent)
            // Add a prominent stop action button
            .addAction(
                android.R.drawable.ic_delete, 
                stopLabel, 
                stopPendingIntent
            )
            // Add a secondary hide button (same behavior as stop)
            // This matches the previous Flutter notification UX where "Hide" stops the Athan.
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                hideLabel,
                stopPendingIntent
            )
            .setOngoing(true)
            .setAutoCancel(false)
            // Full screen intent for lock screen visibility
            .setFullScreenIntent(fullScreenPendingIntent, true)
            // Delete intent (if user swipes)
            .setDeleteIntent(stopPendingIntent)
            .build()
    }

    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "meshkat_elhoda:AthanWakeLock"
        )
        wakeLock?.acquire(10 * 60 * 1000L) // 10 minutes max
        Log.d(TAG, "WakeLock acquired")
    }

    private fun releaseWakeLock() {
        // Release CPU WakeLock
        wakeLock?.let {
            if (it.isHeld) {
                it.release()
                Log.d(TAG, "🔓 CPU WakeLock released")
            }
        }
        wakeLock = null
        
        // Release Screen WakeLock
        screenWakeLock?.let {
            if (it.isHeld) {
                it.release()
                Log.d(TAG, "🔓 Screen WakeLock released")
            }
        }
        screenWakeLock = null
    }

    override fun onDestroy() {
        Log.d(TAG, "Service destroyed")
        try {
            stopReceiver?.let { unregisterReceiver(it) }
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering receiver", e)
        }
        stopAthan()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}

/**
 * Separate BroadcastReceiver for stopping Athan from notification action.
 * This is more reliable than using the service directly on some devices.
 */
class AthanStopReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AthanStopReceiver", "Stop broadcast received")
        
        val stopIntent = Intent(context, AthanForegroundService::class.java).apply {
            action = AthanForegroundService.ACTION_STOP
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(stopIntent)
        } else {
            context.startService(stopIntent)
        }
    }
}
