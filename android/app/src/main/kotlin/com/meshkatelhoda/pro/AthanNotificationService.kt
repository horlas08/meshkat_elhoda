package com.meshkatelhoda.pro

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel

/**
 * Handles Athan notifications with native Android sound playback.
 * The sound plays through NotificationChannel, which works reliably
 * even when app is terminated or screen is off.
 */
class AthanNotificationService(private val context: Context) {
    
    companion object {
        private const val TAG = "AthanNotificationService"
        private const val CHANNEL_ID_PREFIX = "athan_channel_"
        private const val NOTIFICATION_ID = 1001
    }
    
    private val notificationManager: NotificationManager by lazy {
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }
    
    /**
     * Shows Athan notification with the specified muezzin's audio.
     * 
     * @param muezzinId The ID of the selected muezzin (e.g., "ali_almula")
     * @param isFajr Whether this is Fajr prayer (uses fajr audio) or regular
     * @param prayerName The name of the prayer for display (e.g., "Isha", "Fajr")
     * @param title Notification title
     * @param body Notification body
     */
    fun showAthanNotification(
        muezzinId: String,
        isFajr: Boolean,
        prayerName: String,
        title: String,
        body: String
    ) {
        Log.d(TAG, "Showing Athan notification: muezzin=$muezzinId, isFajr=$isFajr, prayer=$prayerName")
        
        // Build audio file name: e.g., "ali_almula_fajr" or "ali_almula_regular"
        val audioFileName = if (isFajr) {
            "${muezzinId}_fajr"
        } else {
            "${muezzinId}_regular"
        }
        
        // Create unique channel ID for this muezzin/type combination
        val channelId = "$CHANNEL_ID_PREFIX${audioFileName}"
        
        // Create notification channel with the correct sound
        createNotificationChannel(channelId, audioFileName, prayerName)
        
        // Build and show notification
        val notification = NotificationCompat.Builder(context, channelId)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm) // Use default alarm icon
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setOngoing(false)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
        
        notificationManager.notify(NOTIFICATION_ID, notification)
        Log.d(TAG, "Athan notification shown successfully")
    }
    
    /**
     * Creates or updates a NotificationChannel with the specified Athan audio.
     */
    private fun createNotificationChannel(channelId: String, audioFileName: String, prayerName: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Delete old channel if exists (to update sound)
            notificationManager.deleteNotificationChannel(channelId)
            
            // Build sound URI from raw resource
            val soundUri = Uri.parse("android.resource://${context.packageName}/raw/$audioFileName")
            Log.d(TAG, "Sound URI: $soundUri")
            
            // Audio attributes for media playback (allows long audio)
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .setUsage(AudioAttributes.USAGE_ALARM) // ALARM ensures it plays even in DND
                .build()
            
            val channel = NotificationChannel(
                channelId,
                "أذان - $prayerName",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "إشعارات الأذان"
                setSound(soundUri, audioAttributes)
                enableVibration(false)
                enableLights(false)
                setBypassDnd(true) // Bypass Do Not Disturb
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            }
            
            notificationManager.createNotificationChannel(channel)
            Log.d(TAG, "Created notification channel: $channelId")
        }
    }
    
    /**
     * Stops any currently playing Athan by cancelling the notification.
     */
    fun stopAthan() {
        notificationManager.cancel(NOTIFICATION_ID)
        Log.d(TAG, "Athan notification cancelled")
    }
}
