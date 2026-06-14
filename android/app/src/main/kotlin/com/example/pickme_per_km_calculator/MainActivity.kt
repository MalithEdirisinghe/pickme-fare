package com.example.pickme_per_km_calculator

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "pickme_per_km_calculator/auto_scan"
    private val prefsName = "auto_scan_prefs"
    private val autoScanActiveKey = "auto_scan_active"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(null)
                }
                "isAccessibilityEnabled" -> result.success(isAutoScannerEnabled())
                "isAutoScanActive" -> result.success(isAutoScanActive())
                "setAutoScanActive" -> {
                    val isActive = call.argument<Boolean>("isActive") ?: true
                    getSharedPreferences(prefsName, MODE_PRIVATE)
                        .edit()
                        .putBoolean(autoScanActiveKey, isActive)
                        .apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isAutoScanActive(): Boolean {
        return getSharedPreferences(prefsName, MODE_PRIVATE)
            .getBoolean(autoScanActiveKey, true)
    }

    private fun isAutoScannerEnabled(): Boolean {
        val expectedService = ComponentName(
            this,
            AutoTripScannerAccessibilityService::class.java,
        ).flattenToString()
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false

        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)
        for (service in splitter) {
            if (service.equals(expectedService, ignoreCase = true)) {
                return true
            }
        }
        return false
    }
}
