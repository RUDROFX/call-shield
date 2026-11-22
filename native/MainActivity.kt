package com.callshield.app

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
    private val roleRequestCode = 4242

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveSettings" -> {
                        val blockForeign = call.argument<Boolean>("blockForeign") ?: true
                        val warnSuspicious = call.argument<Boolean>("warnSuspicious") ?: true
                        val prefs = getSharedPreferences("call_shield_prefs", Context.MODE_PRIVATE)
                        prefs.edit()
                            .putBoolean("block_foreign", blockForeign)
                            .putBoolean("warn_suspicious", warnSuspicious)
                            .apply()
                        result.success(true)
                    }
                    "isScreeningRoleHeld" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            val rm = getSystemService(Context.ROLE_SERVICE) as RoleManager
                            result.success(rm.isRoleHeld(RoleManager.ROLE_CALL_SCREENING))
                        } else {
                            result.success(false)
                        }
                    }
                    "requestScreeningRole" -> {
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
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == roleRequestCode && resultCode == Activity.RESULT_OK) {
            // Role granted; Flutter side re-checks the state.
        }
    }
}
