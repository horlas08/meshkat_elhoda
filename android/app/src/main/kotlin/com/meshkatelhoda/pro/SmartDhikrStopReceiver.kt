package com.meshkatelhoda.pro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class SmartDhikrStopReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "SmartDhikrStop"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "🛑 Stop action received: ${intent.action}")
        val stopIntent = Intent(context, SmartDhikrForegroundService::class.java).apply {
            action = SmartDhikrForegroundService.ACTION_STOP
        }
        try {
            context.startService(stopIntent)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to send stop to service", e)
        }
    }
}
