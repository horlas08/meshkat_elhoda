package com.meshkatelhoda.pro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON" -> {
                
                Log.d("PrayerApp", "🔄 تم إعادة تشغيل الجهاز - إعادة تفعيل الإشعارات")
                
                // هنا WorkManager هيشتغل تلقائياً ويعيد الجدولة
                // Awesome Notifications كمان هتعيد الجدولة
            }
        }
    }
}