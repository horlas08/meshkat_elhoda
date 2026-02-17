package com.meshkatelhoda.pro

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.app.Activity

class AthanAlarmActivity : Activity() {

    companion object {
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val EXTRA_PRAYER_NAME = "prayer_name"

        private const val PREFS_NAME = "meshkat_athan"
        private const val PREF_KEY_STOP_LABEL = "athan_stop_label"
        private const val PREF_KEY_HIDE_LABEL = "athan_hide_label"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
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

        val title = intent.getStringExtra(EXTRA_TITLE) ?: "حان وقت الصلاة"
        val body = intent.getStringExtra(EXTRA_BODY) ?: ""

        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        val stopLabel = prefs.getString(PREF_KEY_STOP_LABEL, "⏹️ إيقاف الأذان") ?: "⏹️ إيقاف الأذان"
        val hideLabel = prefs.getString(PREF_KEY_HIDE_LABEL, "✓ إخفاء") ?: "✓ إخفاء"

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(48, 48, 48, 48)
            setBackgroundColor(0xFF0B1B2B.toInt())
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        val titleView = TextView(this).apply {
            text = title
            textSize = 26f
            setTextColor(0xFFFFD36E.toInt())
            gravity = Gravity.CENTER
        }

        val bodyView = TextView(this).apply {
            text = body
            textSize = 18f
            setTextColor(0xFFE6E6E6.toInt())
            gravity = Gravity.CENTER
        }

        val buttonsRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
        }

        val stopButton = Button(this).apply {
            text = stopLabel
            setOnClickListener {
                stopAthanAndClose()
            }
        }

        val hideButton = Button(this).apply {
            text = hideLabel
            setOnClickListener {
                stopAthanAndClose()
            }
        }

        buttonsRow.addView(stopButton)
        buttonsRow.addView(hideButton)

        root.addView(titleView)
        root.addView(bodyView)
        root.addView(buttonsRow)

        setContentView(root)
    }

    private fun stopAthanAndClose() {
        val stopIntent = Intent(this, AthanForegroundService::class.java).apply {
            action = AthanForegroundService.ACTION_STOP
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(stopIntent)
        } else {
            startService(stopIntent)
        }
        finish()
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        }
        super.onDestroy()
    }
}
