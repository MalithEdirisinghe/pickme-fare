package com.example.pickme_per_km_calculator

import android.accessibilityservice.AccessibilityService
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Display
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.LinearLayout
import android.widget.TextView
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import java.util.Locale
import java.util.concurrent.Executors

class AutoTripScannerAccessibilityService : AccessibilityService() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val screenshotExecutor = Executors.newSingleThreadExecutor()
    private val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
    private val preferenceListener =
        SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
            if (key == AUTO_SCAN_ACTIVE_KEY && !isAutoScanActive()) {
                mainHandler.post { hideOverlay() }
            }
        }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var preferences: SharedPreferences? = null
    private var lastScanAt = 0L
    private var lastResultSignature = ""
    private var scanScheduled = false
    private var lastLayoutExtractionTime = 0L
    private var lastScannedTrip: NativeTripData? = null
    private var lastScannedTripTime = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        preferences = getSharedPreferences(PREFS_NAME, MODE_PRIVATE).also {
            it.registerOnSharedPreferenceChangeListener(preferenceListener)
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val eventType = event?.eventType ?: return
        if (eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
            handleViewClicked(event)
            return
        }
        if (eventType != AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED &&
            eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        ) {
            return
        }

        scheduleScan()
    }

    override fun onInterrupt() {
        hideOverlay()
    }

    override fun onDestroy() {
        hideOverlay()
        preferences?.unregisterOnSharedPreferenceChangeListener(preferenceListener)
        recognizer.close()
        screenshotExecutor.shutdown()
        super.onDestroy()
    }

    private fun scheduleScan() {
        if (!isAutoScanActive()) {
            hideOverlay()
            return
        }
        if (scanScheduled) {
            return
        }

        val now = System.currentTimeMillis()
        if (now - lastScanAt < SCAN_INTERVAL_MS) {
            return
        }

        scanScheduled = true
        mainHandler.postDelayed({
            scanScheduled = false
            lastScanAt = System.currentTimeMillis()
            scanCurrentScreen()
        }, SCAN_DEBOUNCE_MS)
    }

    private fun scanCurrentScreen() {
        if (!isAutoScanActive()) {
            hideOverlay()
            return
        }

        val visibleText = collectVisibleText(rootInActiveWindow)
        val captureTime = System.currentTimeMillis()
        if (tryShowResultFromText(visibleText, isFromScreenshot = false, timestamp = captureTime)) {
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            takeScreenshot(
                Display.DEFAULT_DISPLAY,
                screenshotExecutor,
                object : TakeScreenshotCallback {
                    override fun onSuccess(screenshotResult: ScreenshotResult) {
                        val hardwareBitmap = Bitmap.wrapHardwareBuffer(
                            screenshotResult.hardwareBuffer,
                            screenshotResult.colorSpace,
                        )
                        val softwareBitmap = hardwareBitmap?.copy(
                            Bitmap.Config.ARGB_8888,
                            false,
                        )
                        screenshotResult.hardwareBuffer.close()

                        if (softwareBitmap == null) {
                            return
                        }

                        val image = InputImage.fromBitmap(softwareBitmap, 0)
                        recognizer.process(image)
                            .addOnSuccessListener { recognizedText ->
                                softwareBitmap.recycle()
                                tryShowResultFromText(
                                    recognizedText.text,
                                    isFromScreenshot = true,
                                    timestamp = captureTime
                                )
                            }
                            .addOnFailureListener {
                                softwareBitmap.recycle()
                            }
                    }

                    override fun onFailure(errorCode: Int) = Unit
                },
            )
        }
    }

    private fun collectVisibleText(node: AccessibilityNodeInfo?): String {
        if (node == null) {
            return ""
        }

        val builder = StringBuilder()
        appendNodeText(node, builder)
        return builder.toString()
    }

    private fun appendNodeText(node: AccessibilityNodeInfo, builder: StringBuilder) {
        node.text?.let {
            if (it.isNotBlank()) {
                builder.append(it).append('\n')
            }
        }
        node.contentDescription?.let {
            if (it.isNotBlank()) {
                builder.append(it).append('\n')
            }
        }

        for (index in 0 until node.childCount) {
            node.getChild(index)?.let { child ->
                appendNodeText(child, builder)
                child.recycle()
            }
        }
    }

    private fun tryShowResultFromText(text: String, isFromScreenshot: Boolean, timestamp: Long): Boolean {
        if (!isAutoScanActive()) {
            hideOverlay()
            return false
        }

        if (isFromScreenshot && timestamp <= lastLayoutExtractionTime) {
            return false
        }

        val tripData = extractTripData(text) ?: return false

        // Cache the scanned trip data for auto-saving
        lastScannedTrip = tripData
        lastScannedTripTime = System.currentTimeMillis()

        val totalDistance = tripData.pickupDistance + tripData.tripDistance
        if (totalDistance <= 0.0) {
            return false
        }

        val perKmPrice = tripData.fareAmount / totalDistance
        if (perKmPrice < MIN_REALISTIC_PRICE_PER_KM || perKmPrice > MAX_REALISTIC_PRICE_PER_KM) {
            return false
        }

        if (!isFromScreenshot) {
            lastLayoutExtractionTime = timestamp
        }

        val signature = "${tripData.fareAmount}-${tripData.pickupDistance}-${tripData.tripDistance}"
        if (signature == lastResultSignature) {
            return true
        }

        lastResultSignature = signature
        mainHandler.post {
            showOverlay(
                perKmPrice = perKmPrice,
                fareAmount = tripData.fareAmount,
                totalDistance = totalDistance,
                warning = tripData.warning,
            )
        }
        return true
    }

    private fun cleanOverlayText(text: String): String {
        var cleaned = text
        cleaned = OVERLAY_PRICE_REGEX.replace(cleaned, "")
        cleaned = OVERLAY_DETAILS_REGEX.replace(cleaned, "")
        cleaned = OVERLAY_WARNING_REGEX.replace(cleaned, "")
        return cleaned
    }

    private fun extractTripData(text: String): NativeTripData? {
        val cleanedText = cleanOverlayText(text)
        val fareMatch = FARE_REGEX.find(cleanedText) ?: return null
        val fareAmount = parseOcrNumber(fareMatch.groupValues[1]) ?: return null
        val distances = DISTANCE_REGEX.findAll(cleanedText)
            .mapNotNull { match -> parseOcrNumber(match.groupValues[1]) }
            .toList()

        if (distances.size < 2) {
            return null
        }

        return NativeTripData(
            fareAmount = fareAmount,
            pickupDistance = distances[0],
            tripDistance = distances[1],
            warning = if (distances.size > 2) "Using first two km values" else null,
        )
    }

    private fun showOverlay(
        perKmPrice: Double,
        fareAmount: Double,
        totalDistance: Double,
        warning: String?,
    ) {
        val manager = windowManager ?: return
        hideOverlay()

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(36, 28, 36, 28)
            background = GradientDrawable().apply {
                cornerRadius = 28f
                setColor(Color.argb(235, 20, 20, 20))
            }
        }

        val lowThreshold = preferences?.getFloat("low_threshold", 50f) ?: 50f
        val highThreshold = preferences?.getFloat("high_threshold", 100f) ?: 100f

        val priceColor = when {
            perKmPrice < lowThreshold -> Color.rgb(239, 83, 80) // Red
            perKmPrice >= highThreshold -> Color.rgb(102, 187, 106) // Green
            else -> Color.rgb(255, 167, 38) // Orange
        }

        val priceText = TextView(this).apply {
            text = "${format(perKmPrice)} LKR/km"
            textSize = 30f
            setTextColor(priceColor)
            gravity = Gravity.CENTER
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }
        val detailsText = TextView(this).apply {
            text = "Fare ${format(fareAmount)} LKR  |  Distance ${format(totalDistance)} km"
            textSize = 14f
            setTextColor(Color.rgb(235, 235, 235))
            gravity = Gravity.CENTER
        }

        container.addView(priceText)
        container.addView(detailsText)
        if (warning != null) {
            container.addView(TextView(this).apply {
                text = warning
                textSize = 12f
                setTextColor(Color.rgb(255, 210, 90))
                gravity = Gravity.CENTER
            })
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.CENTER
        }

        overlayView = container
        manager.addView(container, params)
        mainHandler.postDelayed({ hideOverlay() }, OVERLAY_VISIBLE_MS)
    }

    private fun hideOverlay() {
        val view = overlayView ?: return
        windowManager?.removeView(view)
        overlayView = null
    }

    private fun handleViewClicked(event: AccessibilityEvent) {
        if (!isAutoSaveEnabled()) return
        val trip = lastScannedTrip ?: return
        val now = System.currentTimeMillis()
        if (now - lastScannedTripTime > 15000) {
            return // Scanned too long ago (more than 15 seconds)
        }

        val source = event.source
        // Check if click happened on a node containing the accept text, OR check the active window
        if ((source != null && hasAcceptText(source)) || hasAcceptText(rootInActiveWindow)) {
            saveTrip(trip)
            lastScannedTrip = null // Prevent double saving
        }
        source?.recycle()
    }

    private fun hasAcceptText(node: AccessibilityNodeInfo?): Boolean {
        if (node == null) return false
        val text = node.text?.toString() ?: ""
        val desc = node.contentDescription?.toString() ?: ""
        if (text.contains("පිළිගැනීමට", ignoreCase = true) ||
            text.contains("පිළිගන්න", ignoreCase = true) ||
            text.contains("Accept", ignoreCase = true) ||
            desc.contains("පිළිගැනීමට", ignoreCase = true) ||
            desc.contains("පිළිගන්න", ignoreCase = true) ||
            desc.contains("Accept", ignoreCase = true)
        ) {
            return true
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (hasAcceptText(child)) {
                child?.recycle()
                return true
            }
            child?.recycle()
        }
        return false
    }

    private fun saveTrip(trip: NativeTripData) {
        val prefs = preferences ?: return
        val tripsString = prefs.getString("saved_trips_list", "") ?: ""
        val tripsList = if (tripsString.isEmpty()) {
            mutableListOf<String>()
        } else {
            tripsString.split("|||").toMutableList()
        }

        val totalDistance = trip.pickupDistance + trip.tripDistance
        val perKmPrice = if (totalDistance > 0) trip.fareAmount / totalDistance else 0.0
        val timestamp = System.currentTimeMillis()

        // Manual JSON format
        val json = """{"fareAmount":${trip.fareAmount},"pickupDistance":${trip.pickupDistance},"tripDistance":${trip.tripDistance},"totalDistance":$totalDistance,"perKmPrice":$perKmPrice,"timestamp":$timestamp}"""

        tripsList.add(0, json) // Insert at top
        val joined = tripsList.joinToString("|||")
        prefs.edit().putString("saved_trips_list", joined).apply()
    }

    private fun isAutoSaveEnabled(): Boolean {
        return preferences?.getBoolean("auto_save_enabled", false) ?: false
    }

    private fun format(value: Double): String {
        return String.format(Locale.US, "%.2f", value)
    }

    private fun parseOcrNumber(value: String): Double? {
        val normalized = value.trim()
        if (normalized.contains(",") && normalized.contains(".")) {
            return normalized.replace(",", "").toDoubleOrNull()
        }
        if (THOUSANDS_ONLY_REGEX.matches(normalized)) {
            return normalized.replace(",", "").toDoubleOrNull()
        }
        return normalized.replace(',', '.').toDoubleOrNull()
    }

    private fun isAutoScanActive(): Boolean {
        return preferences?.getBoolean(AUTO_SCAN_ACTIVE_KEY, true) ?: true
    }

    private data class NativeTripData(
        val fareAmount: Double,
        val pickupDistance: Double,
        val tripDistance: Double,
        val warning: String?,
    )

    private companion object {
        const val SCAN_DEBOUNCE_MS = 450L
        const val SCAN_INTERVAL_MS = 1200L
        const val OVERLAY_VISIBLE_MS = 6500L
        const val PREFS_NAME = "auto_scan_prefs"
        const val AUTO_SCAN_ACTIVE_KEY = "auto_scan_active"
        const val MIN_REALISTIC_PRICE_PER_KM = 30.0
        const val MAX_REALISTIC_PRICE_PER_KM = 600.0
        val FARE_REGEX = Regex(
            """((?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?|\d+(?:,\d+)?)\s*(?:lkr|rs\.?)""",
            RegexOption.IGNORE_CASE,
        )
        val DISTANCE_REGEX = Regex(
            """((?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?|\d+(?:,\d+)?)\s*(?:km|kms|kilometer|kilometers)\b""",
            RegexOption.IGNORE_CASE,
        )
        val THOUSANDS_ONLY_REGEX = Regex("""^\d{1,3}(?:,\d{3})+$""")
        val OVERLAY_PRICE_REGEX = Regex("""[\d.,]+\s*LKR/km""", RegexOption.IGNORE_CASE)
        val OVERLAY_DETAILS_REGEX = Regex("""Fare\s+[\d.,]+\s*LKR\s*\|\s*Distance\s+[\d.,]+\s*km""", RegexOption.IGNORE_CASE)
        val OVERLAY_WARNING_REGEX = Regex("""Using first two km values""", RegexOption.IGNORE_CASE)
    }
}
