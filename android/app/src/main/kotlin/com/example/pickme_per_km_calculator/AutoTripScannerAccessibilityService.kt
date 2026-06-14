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

    override fun onServiceConnected() {
        super.onServiceConnected()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        preferences = getSharedPreferences(PREFS_NAME, MODE_PRIVATE).also {
            it.registerOnSharedPreferenceChangeListener(preferenceListener)
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val eventType = event?.eventType ?: return
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
        if (tryShowResultFromText(visibleText)) {
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
                                tryShowResultFromText(recognizedText.text)
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

    private fun tryShowResultFromText(text: String): Boolean {
        if (!isAutoScanActive()) {
            hideOverlay()
            return false
        }

        val tripData = extractTripData(text) ?: return false
        val totalDistance = tripData.pickupDistance + tripData.tripDistance
        if (totalDistance <= 0.0) {
            return false
        }

        val perKmPrice = tripData.fareAmount / totalDistance
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

    private fun extractTripData(text: String): NativeTripData? {
        val fareMatch = FARE_REGEX.find(text) ?: return null
        val fareAmount = parseOcrNumber(fareMatch.groupValues[1]) ?: return null
        val distances = DISTANCE_REGEX.findAll(text)
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

        val priceText = TextView(this).apply {
            text = "${format(perKmPrice)} LKR/km"
            textSize = 30f
            setTextColor(Color.WHITE)
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
        val FARE_REGEX = Regex(
            """((?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?|\d+(?:,\d+)?)\s*(?:lkr|rs\.?)""",
            RegexOption.IGNORE_CASE,
        )
        val DISTANCE_REGEX = Regex(
            """((?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?|\d+(?:,\d+)?)\s*(?:km|kms|kilometer|kilometers)\b""",
            RegexOption.IGNORE_CASE,
        )
        val THOUSANDS_ONLY_REGEX = Regex("""^\d{1,3}(?:,\d{3})+$""")
    }
}
