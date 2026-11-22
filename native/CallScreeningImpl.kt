package com.callshield.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import androidx.core.app.NotificationCompat

class CallScreeningImpl : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val prefs = getSharedPreferences("call_shield_prefs", Context.MODE_PRIVATE)
        val blockForeign = prefs.getBoolean("block_foreign", true)
        val warnSuspicious = prefs.getBoolean("warn_suspicious", true)

        // Outgoing calls are never touched.
        if (callDetails.callDirection != Call.Details.DIRECTION_INCOMING) {
            respondToCall(callDetails, CallResponse.Builder().build())
            return
        }

        val raw = callDetails.handle?.schemeSpecificPart ?: ""
        val number = normalize(raw)

        val responseBuilder = CallResponse.Builder()

        if (number.isEmpty()) {
            // Hidden or unknown number: let it ring.
            respondToCall(callDetails, responseBuilder.build())
            return
        }

        val isBangladeshi = isBangladeshiNumber(number)

        if (!isBangladeshi && blockForeign && number.startsWith("+")) {
            responseBuilder
                .setDisallowCall(true)
                .setRejectCall(true)
                .setSkipCallLog(false)
                .setSkipNotification(true)
            respondToCall(callDetails, responseBuilder.build())
            notifyUser("বিদেশি কল ব্লক করা হয়েছে", number)
            return
        }

        if (isBangladeshi && warnSuspicious && isSuspicious(number)) {
            notifyUser("সন্দেহজনক কল, সাবধান!", number)
        }

        respondToCall(callDetails, responseBuilder.build())
    }

    private fun normalize(input: String): String {
        val cleaned = input.replace(Regex("[\\s\\-()]"), "")
        return when {
            cleaned.startsWith("00") -> "+" + cleaned.substring(2)
            else -> cleaned
        }
    }

    private fun isBangladeshiNumber(number: String): Boolean {
        // +8801XXXXXXXXX, 8801XXXXXXXXX, 01XXXXXXXXX
        return Regex("^(\\+?880|0)1[3-9]\\d{8}$").matches(number) ||
            number.startsWith("+880") ||
            (!number.startsWith("+") && number.startsWith("0"))
    }

    private fun isSuspicious(number: String): Boolean {
        val local = number
            .removePrefix("+880")
            .removePrefix("880")
            .removePrefix("0")

        // A valid mobile number is 10 digits starting with 1.
        if (local.startsWith("1") && local.length != 10) return true

        // Same digit repeated 6+ times in a row.
        if (Regex("(\\d)\\1{5,}").containsMatchIn(local)) return true

        // Very long or very short numbers.
        if (local.length > 11 || local.length < 5) return true

        return false
    }

    private fun notifyUser(title: String, number: String) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "call_shield_alerts"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Call Shield Alerts",
                NotificationManager.IMPORTANCE_HIGH
            )
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle(title)
            .setContentText(number)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        manager.notify(System.currentTimeMillis().toInt(), notification)
    }
}
