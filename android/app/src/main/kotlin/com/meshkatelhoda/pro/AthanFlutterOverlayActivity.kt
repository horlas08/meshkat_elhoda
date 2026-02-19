package com.meshkatelhoda.pro

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AthanFlutterOverlayActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.meshkatelhoda.pro/athan_overlay"

        @Volatile
        private var lastTitle: String? = null

        @Volatile
        private var lastBody: String? = null

        @Volatile
        private var lastPrayerName: String? = null

        fun updateOverlayDataFromIntent(intent: Intent?) {
            if (intent == null) return
            lastTitle = intent.getStringExtra(AthanAlarmActivity.EXTRA_TITLE)
            lastBody = intent.getStringExtra(AthanAlarmActivity.EXTRA_BODY)
            lastPrayerName = intent.getStringExtra(AthanAlarmActivity.EXTRA_PRAYER_NAME)
        }
    }

    override fun getInitialRoute(): String {
        return "/athanOverlay"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        updateOverlayDataFromIntent(intent)
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }

        @Suppress("DEPRECATION")
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        updateOverlayDataFromIntent(intent)

        // If Flutter engine already running, push latest data to Dart side.
        try {
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod(
                    "setOverlayData",
                    mapOf(
                        "title" to (lastTitle ?: ""),
                        "body" to (lastBody ?: ""),
                        "prayerName" to (lastPrayerName ?: "")
                    )
                )
            }
        } catch (_: Exception) {
            // ignore
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getOverlayData" -> {
                        result.success(
                            mapOf(
                                "title" to (lastTitle ?: ""),
                                "body" to (lastBody ?: ""),
                                "prayerName" to (lastPrayerName ?: "")
                            )
                        )
                    }

                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        }
        super.onDestroy()
    }
}
