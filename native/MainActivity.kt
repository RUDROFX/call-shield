package com.callshield.call_shield

import android.app.Activity
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "call_shield/native"
    private val prefsName = "call_shield_prefs"
    private val roleRequestCode = 4242

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                val prefs = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
                when (call.method) {
                    "getSettings" -> {
                        val map = HashMap<String, Any>()
                        map["enabled"] = prefs.getBoolean("enabled", true)
                        map["blockForeign"] = prefs.getBoolean("block_foreign", true)
                        map["warnSuspicious"] = prefs.getBoolean("warn_suspicious", true)
                        result.success(map)
                    }
                    "saveSettings" -> {
                        prefs.edit()
                            .putBoolean("enabled", call.argument<Boolean>("enabled") ?: true)
                            .putBoolean("block_foreign", call.argument<Boolean>("blockForeign") ?: true)
                            .putBoolean("warn_suspicious", call.argument<Boolean>("warnSuspicious") ?: true)
                            .apply()
                        result.success(true)
                    }
                    "getLogs" -> {
                        result.success(prefs.getString("call_logs", "[]"))
                    }
                    "clearLogs" -> {
                        prefs.edit().putString("call_logs", "[]").apply()
                        result.success(true)
                    }
                    "isRoleHeld" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            val rm = getSystemService(Context.ROLE_SERVICE) as RoleManager
                            result.success(rm.isRoleHeld(RoleManager.ROLE_CALL_SCREENING))
                        } else {
                            result.success(false)
                        }
                    }
                    "requestRole" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            val rm = getSystemService(Context.ROLE_SERVICE) as RoleManager
                            if (rm.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING) &&
                                !rm.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
                            ) {
                                val intent: Intent =
                                    rm.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                                startActivityForResult(intent, roleRequestCode)
                            }
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    "requestNotificationPermission" -> {
                        if (Build.VERSION.SDK_INT >= 33) {
                            requestPermissions(arrayOf("android.permission.POST_NOTIFICATIONS"), 101)
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == roleRequestCode && resultCode == Activity.RESULT_OK) {
            // Role granted. The Flutter side re-checks when the app resumes.
        }
    }
}
