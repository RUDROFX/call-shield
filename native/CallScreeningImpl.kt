package com.callshield.call_shield

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject

class CallScreeningImpl : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val prefs = getSharedPreferences("call_shield_prefs", Context.MODE_PRIVATE)
        val enabled = prefs.getBoolean("enabled", true)
        val blockForeign = prefs.getBoolean("block_foreign", true)
        val warnSuspicious = prefs.getBoolean("warn_suspicious", true)

        // Outgoing calls and a paused shield are never touched.
        if (!enabled || callDetails.callDirection != Call.Details.DIRECTION_INCOMING) {
            respondToCall(callDetails, CallResponse.Builder().build())
            return
        }

        val raw = callDetails.handle?.schemeSpecificPart ?: ""
        if (raw.isEmpty()) {
            safeLog("", "allowed", "Hidden number")
            respondToCall(callDetails, CallResponse.Builder().build())
            return
        }

        val (isForeign, reason) = analyze(raw)

        if (isForeign && blockForeign) {
            val response = CallResponse.Builder()
                .setDisallowCall(true)
                .setRejectCall(true)
                .setSkipCallLog(false)
                .setSkipNotification(true)
                .build()
            respondToCall(callDetails, response)
            safeLog(raw, "blocked", "Foreign")
            return
        }

        if (!isForeign && reason != null && warnSuspicious) {
            safeLog(raw, "warned", reason)
            try {
                notifyUser("Suspicious call", raw + " - " + reason)
            } catch (e: Exception) {
            }
        } else {
            safeLog(raw, "allowed", "")
        }

        respondToCall(callDetails, CallResponse.Builder().build())
    }

    private fun hasRepeat(s: String): Boolean {
        var run = 1
        for (i in 1 until s.length) {
            run = if (s[i] == s[i - 1]) run + 1 else 1
            if (run >= 6) return true
        }
        return false
    }

    // Returns (isForeign, suspiciousReason)
    private fun analyze(raw: String): Pair<Boolean, String?> {
        var n = raw.filter { it.isDigit() || it == '+' }
        if (n.startsWith("00")) n = "+" + n.substring(2)
        if (n.isEmpty()) return Pair(false, null)

        if (n.startsWith("+") && !n.startsWith("+880")) {
            return Pair(true, null)
        }

        var local = n
        if (local.startsWith("+880")) {
            local = "0" + local.substring(4)
        } else if (local.startsWith("880") && local.length >= 12) {
            local = "0" + local.substring(3)
        }

        var reason: String? = null
        if (local.startsWith("01")) {
            if (local.length != 11) {
                reason = "Invalid mobile number length"
            } else if ("012".contains(local[2])) {
                reason = "Unknown operator code"
            }
        } else if (local.startsWith("0")) {
            if (local.length < 9 || local.length > 11) {
                reason = "Unusual landline length"
            }
        } else if (local.length >= 7) {
            reason = "Unrecognized number format"
        }

        if (reason == null && hasRepeat(local)) {
            reason = "Repeating digits"
        }
        return Pair(false, reason)
    }

    private fun safeLog(number: String, status: String, detail: String) {
        try {
            val prefs = getSharedPreferences("call_shield_prefs", Context.MODE_PRIVATE)
            val old = try {
                JSONArray(prefs.getString("call_logs", "[]"))
            } catch (e: Exception) {
                JSONArray()
            }
            val entry = JSONObject()
            entry.put("number", number)
            entry.put("status", status)
            entry.put("detail", detail)
            entry.put("time", System.currentTimeMillis())

            val out = JSONArray()
            out.put(entry)
            val keep = if (old.length() < 49) old.length() else 49
            for (i in 0 until keep) {
                out.put(old.get(i))
            }
            prefs.edit().putString("call_logs", out.toString()).apply()
        } catch (e: Exception) {
        }
    }

    private fun notifyUser(title: String, text: String) {
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
            .setContentText(text)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        manager.notify(System.currentTimeMillis().toInt(), notification)
    }
}
