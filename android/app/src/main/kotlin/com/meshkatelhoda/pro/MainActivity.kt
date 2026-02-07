package com.meshkatelhoda.pro

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.work.Configuration
import androidx.work.WorkManager
import android.util.Log
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings

class MainActivity: AudioServiceActivity() {
    
    companion object {
        private const val TAG = "MainActivity"
        private const val ATHAN_CHANNEL = "com.meshkatelhoda.pro/athan"
    }
    
    private lateinit var athanService: AthanNotificationService
    private lateinit var athanAlarmManager: AthanAlarmManager
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "🚀 Configuring Flutter Engine with MethodChannel...")
        
        // Initialize services
        athanService = AthanNotificationService(applicationContext)
        athanAlarmManager = AthanAlarmManager(applicationContext)
        
        // Setup MethodChannel for Athan
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ATHAN_CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "📞 MethodChannel call: ${call.method}")
            
            when (call.method) {
                // Check if exact alarm permission is granted (Android 12+)
                "canScheduleExactAlarms" -> {
                    result.success(canScheduleExactAlarms())
                }
                
                // Open settings to request exact alarm permission
                "requestExactAlarmPermission" -> {
                    openExactAlarmSettings()
                    result.success(true)
                }
                
                // Play Athan immediately (for testing or manual trigger)
                "playAthan" -> {
                    try {
                        val muezzinId = call.argument<String>("muezzinId") ?: "ali_almula"
                        val isFajr = call.argument<Boolean>("isFajr") ?: false
                        val prayerName = call.argument<String>("prayerName") ?: "Prayer"
                        val title = call.argument<String>("title") ?: "حان وقت الصلاة"
                        val body = call.argument<String>("body") ?: "حان الآن موعد صلاة $prayerName"
                        
                        Log.d(TAG, "▶️ Playing Athan: muezzin=$muezzinId, isFajr=$isFajr, prayer=$prayerName")
                        
                        // Use AthanNotificationService directly to avoid background service warnings
                        athanService.showAthanNotification(
                            muezzinId = muezzinId,
                            isFajr = isFajr,
                            prayerName = prayerName,
                            title = title,
                            body = body
                        )
                        
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Error playing Athan", e)
                        result.error("ATHAN_ERROR", e.message, null)
                    }
                }
                
                // Schedule Athan for a future time using AlarmManager
                "scheduleAthan" -> {
                    try {
                        // Check permission first
                        if (!canScheduleExactAlarms()) {
                            Log.w(TAG, "⚠️ Exact alarm permission not granted!")
                            result.error("PERMISSION_DENIED", "Exact alarm permission not granted. Please enable in settings.", null)
                            return@setMethodCallHandler
                        }
                        
                        val prayerId = call.argument<Int>("prayerId") ?: 1
                        val triggerTimeMillis = call.argument<Long>("triggerTimeMillis") ?: 0L
                        val muezzinId = call.argument<String>("muezzinId") ?: "ali_almula"
                        val isFajr = call.argument<Boolean>("isFajr") ?: false
                        val prayerName = call.argument<String>("prayerName") ?: "Prayer"
                        val title = call.argument<String>("title") ?: "حان وقت الصلاة"
                        val body = call.argument<String>("body") ?: "حان الآن موعد صلاة $prayerName"
                        
                        Log.d(TAG, "⏰ Scheduling Athan: prayerId=$prayerId, time=$triggerTimeMillis, muezzin=$muezzinId")
                        
                        athanAlarmManager.scheduleAthanAlarm(
                            prayerId = prayerId,
                            triggerTimeMillis = triggerTimeMillis,
                            muezzinId = muezzinId,
                            isFajr = isFajr,
                            prayerName = prayerName,
                            title = title,
                            body = body
                        )
                        
                        Log.d(TAG, "✅ Athan scheduled successfully")
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Error scheduling Athan", e)
                        result.error("ATHAN_ERROR", e.message, null)
                    }
                }
                
                // Cancel a specific scheduled Athan
                "cancelAthan" -> {
                    try {
                        val prayerId = call.argument<Int>("prayerId") ?: 1
                        athanAlarmManager.cancelAthanAlarm(prayerId)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Error cancelling Athan", e)
                        result.error("ATHAN_ERROR", e.message, null)
                    }
                }
                
                // Cancel all scheduled Athans
                "cancelAllAthans" -> {
                    try {
                        athanAlarmManager.cancelAllAthanAlarms()
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Error cancelling all Athans", e)
                        result.error("ATHAN_ERROR", e.message, null)
                    }
                }
                
                // Stop currently playing Athan
                "stopAthan" -> {
                    try {
                        // Stop Notification Service
                        athanService.stopAthan()
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Error stopping Athan", e)
                        result.error("ATHAN_ERROR", e.message, null)
                    }
                }
                
                // ✅ Check if app is being battery optimized
                "isBatteryOptimized" -> {
                    result.success(isBatteryOptimized())
                }
                
                // ✅ Request battery optimization exemption
                "requestBatteryOptimizationExemption" -> {
                    requestBatteryOptimizationExemption()
                    result.success(true)
                }

                // ✅ Open App Info settings
                "openAppSettings" -> {
                    openAppSettings()
                    result.success(true)
                }
                
                else -> {
                    Log.w(TAG, "⚠️ Unknown method: ${call.method}")
                    result.notImplemented()
                }
            }
        }
        
        Log.d(TAG, "✅ MethodChannel registered successfully")
        
        // ✅ Initialize WorkManager
        try {
            val config = Configuration.Builder()
                .setMinimumLoggingLevel(android.util.Log.INFO)
                .build()
            WorkManager.initialize(applicationContext, config)
        } catch (e: IllegalStateException) {
            // WorkManager already initialized
        }
        
        // Check and log exact alarm permission status
        Log.d(TAG, "📅 Can schedule exact alarms: ${canScheduleExactAlarms()}")
        Log.d(TAG, "🔋 Is battery optimized: ${isBatteryOptimized()}")
    }
    
    /**
     * Check if the app can schedule exact alarms (Android 12+)
     */
    private fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            true // Always true for Android 11 and below
        }
    }
    
    /**
     * Open system settings for exact alarm permission
     */
    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
            } catch (e: Exception) {
                Log.e(TAG, "Error opening exact alarm settings", e)
            }
        }
    }
    
    /**
     * ✅ Check if the app is being battery optimized (which can prevent Athan from working)
     */
    private fun isBatteryOptimized(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
            return !powerManager.isIgnoringBatteryOptimizations(packageName)
        }
        return false // No battery optimization on older Android versions
    }
    
    /**
     * ✅ Request battery optimization exemption
     * On many devices, ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS shows a system dialog.
     * On others, it may do nothing. Falls back to the optimization settings list.
     */
    private fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
            val isIgnoring = powerManager.isIgnoringBatteryOptimizations(packageName)
            
            if (isIgnoring) {
                Log.d(TAG, "🔋 Already ignoring battery optimizations")
                return
            }

            try {
                // Primary: Try to show the direct system dialog (requires permission in manifest)
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                intent.data = android.net.Uri.parse("package:$packageName")
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
                Log.d(TAG, "🔋 Opened direct battery optimization dialog")
            } catch (e: Exception) {
                Log.e(TAG, "Error opening direct battery dialog, falling back to settings list", e)
                try {
                    // Fallback: Open the general battery optimization settings list
                    val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    fallbackIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(fallbackIntent)
                    Log.d(TAG, "🔋 Opened general battery optimization settings list")
                } catch (e2: Exception) {
                    Log.e(TAG, "Error opening fallback battery list, falling back to app settings", e2)
                    openAppSettings() // Last resort
                }
            }
        }
    }

    /**
     * ✅ Open the system app settings page for this app
     */
    private fun openAppSettings() {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            val uri = android.net.Uri.fromParts("package", packageName, null)
            intent.data = uri
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
            Log.d(TAG, "⚙️ Opened App Settings")
        } catch (e: Exception) {
            Log.e(TAG, "Error opening app settings", e)
        }
    }
}