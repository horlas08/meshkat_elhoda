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
import kotlin.random.Random

class SmartDhikrForegroundService : Service() {

    companion object {
        private const val TAG = "SmartDhikrService"
        private const val NOTIFICATION_ID = 3001
        private const val CHANNEL_ID = "smart_dhikr_foreground_channel"

        const val EXTRA_ALARM_ID = "alarm_id"
        const val ACTION_STOP = "com.meshkatelhoda.pro.STOP_SMART_DHIKR"

        private val FALLBACK_URLS = listOf(
            "http://www.hisnmuslim.com/audio/ar/91.mp3",
            "http://www.hisnmuslim.com/audio/ar/92.mp3",
            "http://www.hisnmuslim.com/audio/ar/93.mp3",
            "http://www.hisnmuslim.com/audio/ar/94.mp3",
            "http://www.hisnmuslim.com/audio/ar/96.mp3",
            "http://www.hisnmuslim.com/audio/ar/97.mp3",
            "http://www.hisnmuslim.com/audio/ar/98.mp3",
            "http://www.hisnmuslim.com/audio/ar/99.mp3",
            "http://www.hisnmuslim.com/audio/ar/100.mp3",
            "http://www.hisnmuslim.com/audio/ar/101.mp3",
            "http://www.hisnmuslim.com/audio/ar/102.mp3",
            "http://www.hisnmuslim.com/audio/ar/103.mp3"
        )
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var stopReceiver: BroadcastReceiver? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🔊 Service created")
        createNotificationChannel()
        releaseBroadcastReceiverWakeLock()
        acquireWakeLock()
        registerStopReceiver()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == ACTION_STOP) {
            stopPlaybackAndSelf()
            return START_NOT_STICKY
        }

        val alarmId = intent?.getIntExtra(EXTRA_ALARM_ID, 1) ?: 1
        Log.d(TAG, "▶️ Starting Smart Dhikr playback (alarmId=$alarmId)")

        startForeground(NOTIFICATION_ID, buildNotification())
        startPlayback()

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun buildNotification(): android.app.Notification {
        val openIntent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        val openPendingIntent = PendingIntent.getActivity(
            this,
            0,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = Intent(this, SmartDhikrStopReceiver::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Smart Voice")
            .setContentText("Playing dhikr...")
            .setSmallIcon(android.R.drawable.ic_lock_silent_mode_off)
            .setContentIntent(openPendingIntent)
            .setOngoing(true)
            .addAction(android.R.drawable.ic_delete, "Stop", stopPendingIntent)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .build()
    }

    private fun startPlayback() {
        stopPlaybackOnly()

        val source = pickLocalFilePath() ?: pickFallbackUrl()
        Log.d(TAG, "🎧 Playing source: $source")

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
                Log.d(TAG, "✅ Smart Dhikr completed")
                stopPlaybackAndSelf()
            }
            mp.setOnErrorListener { _, what, extra ->
                Log.e(TAG, "❌ MediaPlayer error what=$what extra=$extra")
                stopPlaybackAndSelf()
                true
            }

            mp.prepare()
            mp.start()
            mediaPlayer = mp
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to start playback", e)
            stopPlaybackAndSelf()
        }
    }

    private fun pickLocalFilePath(): String? {
        return try {
            val baseDir = File(filesDir.parentFile, "app_flutter/smart_dhikr_audio")
            if (!baseDir.exists() || !baseDir.isDirectory) return null

            val mp3s = baseDir.listFiles { f -> f.isFile && f.name.endsWith(".mp3") }?.toList() ?: emptyList()
            if (mp3s.isEmpty()) return null

            val file = mp3s[Random.nextInt(mp3s.size)]
            file.absolutePath
        } catch (e: Exception) {
            null
        }
    }

    private fun pickFallbackUrl(): String {
        return FALLBACK_URLS[Random.nextInt(FALLBACK_URLS.size)]
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
                "meshkat_elhoda:SmartDhikrServiceWakeLock"
            ).apply {
                acquire(2 * 60 * 1000L)
            }
            Log.d(TAG, "🔒 WakeLock acquired in service")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to acquire WakeLock", e)
        }
    }

    private fun releaseBroadcastReceiverWakeLock() {
        try {
            SmartDhikrBroadcastReceiver.wakeLock?.let {
                if (it.isHeld) {
                    it.release()
                    Log.d(TAG, "🔓 Released BroadcastReceiver WakeLock")
                }
            }
            SmartDhikrBroadcastReceiver.wakeLock = null
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing BroadcastReceiver WakeLock", e)
        }
    }

    private fun registerStopReceiver() {
        stopReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == ACTION_STOP) {
                    Log.d(TAG, "🛑 Stop broadcast received")
                    stopPlaybackAndSelf()
                }
            }
        }
        try {
            registerReceiver(stopReceiver, IntentFilter(ACTION_STOP))
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to register stop receiver", e)
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
                "Smart Dhikr",
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
        Log.d(TAG, "🧹 Service destroyed")
    }
}
