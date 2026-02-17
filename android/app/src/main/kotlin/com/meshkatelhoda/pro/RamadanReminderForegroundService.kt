package com.meshkatelhoda.pro

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
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import java.io.File

class RamadanReminderForegroundService : Service() {

    companion object {
        private const val TAG = "RamadanService"
        private const val NOTIFICATION_ID = 4001
        const val CHANNEL_ID = "ramadan_foreground_channel"

        const val EXTRA_TYPE = "type"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"

        const val ACTION_STOP = "com.meshkatelhoda.pro.STOP_RAMADAN_REMINDER"

        private const val FALLBACK_SUHOOR_URL = "http://www.hisnmuslim.com/audio/ar/96.mp3"
        private const val FALLBACK_IFTAR_URL = "http://www.hisnmuslim.com/audio/ar/103.mp3"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var stopReceiver: BroadcastReceiver? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        releaseBroadcastReceiverWakeLock()
        acquireWakeLock()
        registerStopReceiver()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopPlaybackAndSelf()
            return START_NOT_STICKY
        }

        val type = intent?.getStringExtra(EXTRA_TYPE) ?: RamadanReminderAlarmManager.TYPE_SUHOOR
        val title = intent?.getStringExtra(EXTRA_TITLE) ?: ""
        val body = intent?.getStringExtra(EXTRA_BODY) ?: ""

        startForeground(NOTIFICATION_ID, buildNotification(title, body))
        startPlayback(type)

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun buildNotification(title: String, body: String): android.app.Notification {
        val openIntent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        val openPendingIntent = PendingIntent.getActivity(
            this,
            0,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = Intent(this, RamadanReminderStopReceiver::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentIntent(openPendingIntent)
            .setOngoing(true)
            .addAction(android.R.drawable.ic_delete, "Stop", stopPendingIntent)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .build()
    }

    private fun startPlayback(type: String) {
        stopPlaybackOnly()

        val localPath = pickLocalFilePath(if (type == RamadanReminderAlarmManager.TYPE_IFTAR) "103" else "96")
        val source = localPath ?: if (type == RamadanReminderAlarmManager.TYPE_IFTAR) FALLBACK_IFTAR_URL else FALLBACK_SUHOOR_URL

        try {
            val mp = MediaPlayer()
            mp.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )

            if (source.startsWith("http")) {
                mp.setDataSource(source)
            } else {
                mp.setDataSource(this, android.net.Uri.fromFile(File(source)))
            }

            mp.setOnCompletionListener {
                stopPlaybackAndSelf()
            }
            mp.setOnErrorListener { _, _, _ ->
                stopPlaybackAndSelf()
                true
            }

            mp.prepare()
            mp.start()
            mediaPlayer = mp
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start Ramadan playback", e)
            stopPlaybackAndSelf()
        }
    }

    private fun pickLocalFilePath(id: String): String? {
        return try {
            val baseDir = File(filesDir.parentFile, "app_flutter/smart_dhikr_audio")
            val f = File(baseDir, "$id.mp3")
            if (f.exists() && f.isFile) f.absolutePath else null
        } catch (_: Exception) {
            null
        }
    }

    private fun stopPlaybackOnly() {
        try {
            mediaPlayer?.let {
                try {
                    if (it.isPlaying) it.stop()
                } catch (_: Exception) {
                }
                it.reset()
                it.release()
            }
        } catch (_: Exception) {
        } finally {
            mediaPlayer = null
        }
    }

    private fun stopPlaybackAndSelf() {
        stopPlaybackOnly()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun acquireWakeLock() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "meshkat_elhoda:RamadanServiceWakeLock"
            ).apply {
                acquire(2 * 60 * 1000L)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to acquire wake lock", e)
        }
    }

    private fun releaseBroadcastReceiverWakeLock() {
        try {
            RamadanReminderReceiver.wakeLock?.let {
                if (it.isHeld) it.release()
            }
            RamadanReminderReceiver.wakeLock = null
        } catch (_: Exception) {
        }
    }

    private fun registerStopReceiver() {
        stopReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == ACTION_STOP) {
                    stopPlaybackAndSelf()
                }
            }
        }
        try {
            registerReceiver(stopReceiver, IntentFilter(ACTION_STOP))
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register stop receiver", e)
        }
    }

    private fun unregisterStopReceiver() {
        try {
            stopReceiver?.let { unregisterReceiver(it) }
        } catch (_: Exception) {
        } finally {
            stopReceiver = null
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Ramadan Reminders",
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.setSound(null, null)
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterStopReceiver()
        stopPlaybackOnly()
        try {
            wakeLock?.let { if (it.isHeld) it.release() }
        } catch (_: Exception) {
        } finally {
            wakeLock = null
        }
    }
}
