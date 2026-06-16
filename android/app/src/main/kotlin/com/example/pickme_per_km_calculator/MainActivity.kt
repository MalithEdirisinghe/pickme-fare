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
                "getThresholds" -> {
                    val prefs = getSharedPreferences(prefsName, MODE_PRIVATE)
                    val low = prefs.getFloat("low_threshold", 50f)
                    val high = prefs.getFloat("high_threshold", 100f)
                    result.success(mapOf("low" to low.toDouble(), "high" to high.toDouble()))
                }
                "setThresholds" -> {
                    val low = call.argument<Double>("low") ?: 50.0
                    val high = call.argument<Double>("high") ?: 100.0
                    getSharedPreferences(prefsName, MODE_PRIVATE)
                        .edit()
                        .putFloat("low_threshold", low.toFloat())
                        .putFloat("high_threshold", high.toFloat())
                        .apply()
                    result.success(null)
                }
                "getSavedTrips" -> {
                    val prefs = getSharedPreferences(prefsName, MODE_PRIVATE)
                    val tripsString = prefs.getString("saved_trips_list", "") ?: ""
                    val tripsList = if (tripsString.isEmpty()) {
                        emptyList<String>()
                    } else {
                        tripsString.split("|||")
                    }
                    result.success(tripsList)
                }
                "clearSavedTrips" -> {
                    getSharedPreferences(prefsName, MODE_PRIVATE).edit().remove("saved_trips_list").apply()
                    result.success(null)
                }
                "isAutoSaveEnabled" -> {
                    val prefs = getSharedPreferences(prefsName, MODE_PRIVATE)
                    result.success(prefs.getBoolean("auto_save_enabled", false))
                }
                "setAutoSaveEnabled" -> {
                    val isEnabled = call.argument<Boolean>("isEnabled") ?: false
                    getSharedPreferences(prefsName, MODE_PRIVATE).edit().putBoolean("auto_save_enabled", isEnabled).apply()
                    result.success(null)
                }
                "getLanguage" -> {
                    val prefs = getSharedPreferences(prefsName, MODE_PRIVATE)
                    result.success(prefs.getString("app_language", "en") ?: "en")
                }
                "setLanguage" -> {
                    val lang = call.argument<String>("language") ?: "en"
                    getSharedPreferences(prefsName, MODE_PRIVATE).edit().putString("app_language", lang).apply()
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
