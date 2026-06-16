import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../providers/trip_calculator_provider.dart';
import '../widgets/result_card.dart';
import '../widgets/screenshot_preview.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'FareRate',
      'auto_scan': 'Auto Scan',
      'manual_scan': 'Manual Scan',
      'history': 'History',
      'hello_driver': 'Hello, Driver!',
      'greeting_subtitle':
          'Track your PickMe fare rate per kilometer and maximize your earnings.',
      'auto_scanner': 'Auto Scanner',
      'active': 'ACTIVE',
      'inactive': 'INACTIVE',
      'scanner_desc_active':
          'The app is listening. Keep the PickMe Driver app open; the per-km rate popup overlay will appear automatically.',
      'scanner_desc_paused':
          'Accessibility is enabled, but screen reading is currently paused.',
      'scanner_desc_inactive':
          'Enable accessibility service once to allow the app to detect fares on your screen automatically.',
      'auto_screen_read': 'Auto screen read',
      'auto_screen_read_sub': 'Read screens automatically',
      'auto_save_trips': 'Auto-save accepted trips',
      'auto_save_trips_sub': 'Save details when you tap accept',
      'enable_auto_popup': 'Enable Auto Popup',
      'refresh_status': 'Refresh status',
      'fare_threshold_settings': 'Fare Threshold Settings',
      'threshold_subtitle':
          'Set fare thresholds to color-code per-km rate (LKR/km)',
      'low_threshold': 'Low Threshold',
      'high_threshold': 'High Threshold',
      'save_settings': 'Save Settings',
      'save_success': 'Threshold settings saved successfully',
      'manual_scanner': 'Manual Scanner',
      'manual_scanner_desc':
          'Select a screenshot of the PickMe hire card from your gallery to calculate the rate manually.',
      'select_image': 'Select Image',
      'start_ocr_scan': 'Start OCR Scan',
      'scanning': 'Scanning...',
      'ocr_text_title': 'OCR Text',
      'saved_trips_title': 'Saved Trips',
      'no_saved_trips': 'No saved trips yet',
      'no_saved_trips_desc':
          'Accepted trips will appear here automatically when the scanner is running.',
      'clear_history_title': 'Clear History?',
      'clear_history_body': 'Do you want to clear all saved trip history?',
      'cancel': 'Cancel',
      'clear': 'Clear',
      'history_cleared': 'History cleared',
      'fare': 'Fare',
      'total_dist': 'Total Dist',
      'trip_dist': 'Trip',
      'pickup_dist': 'Pickup',
      'error_loading_trip': 'Error loading trip details',
    },
    'si': {
      'app_title': 'FareRate',
      'auto_scan': 'ස්කෑනරය',
      'manual_scan': 'ස්ක්‍රීන්ෂොට්',
      'history': 'ඉතිහාසය',
      'hello_driver': 'ආයුබෝවන්!',
      'greeting_subtitle':
          'ඔබගේ PickMe 1km කට ගාස්තුව ස්වයංක්‍රීයව ගණනය කර ආදායම උපරිම කරගන්න.',
      'auto_scanner': 'ස්වයංක්‍රීය ස්කෑනරය',
      'active': 'සක්‍රීයයි',
      'inactive': 'අක්‍රීයයි',
      'scanner_desc_active':
          'ඇප් එක සක්‍රීයයි. PickMe Driver ඇප් එක විවෘතව තබන්න; LKR/km Overlay එක ස්වයංක්‍රීයව දිස්වේ.',
      'scanner_desc_paused':
          'ප්‍රවේශ්‍යතාවය (Accessibility) සක්‍රීයයි, නමුත් ස්වයංක්‍රීය කියවීම තාවකාලිකව නවතා ඇත.',
      'scanner_desc_inactive':
          'සවාරි විස්තර ස්වයංක්‍රීයව කියවීම සඳහා ප්‍රවේශ්‍යතා සේවාව (Accessibility Service) සක්‍රීය කරන්න.',
      'auto_screen_read': 'ස්වයංක්‍රීයව කියවීම',
      'auto_screen_read_sub': 'තිරය ස්වයංක්‍රීයව කියවන්න',
      'auto_save_trips': 'පිළිගත් සවාරි සුරැකීම',
      'auto_save_trips_sub': 'සවාරිය පිළිගත් විට දත්ත සුරකින්න',
      'enable_auto_popup': 'ප්‍රවේශ්‍යතාවය සක්‍රීය කරන්න',
      'refresh_status': 'තත්ත්වය යාවත්කාලීන කරන්න',
      'fare_threshold_settings': 'ගාස්තු සීමාවන් සැකසීම',
      'threshold_subtitle':
          'LKR/km අගය වර්ණ ගැන්වීම සඳහා ගාස්තු සීමාවන් සකසන්න',
      'low_threshold': 'අඩු සීමාව',
      'high_threshold': 'වැඩි සීමාව',
      'save_settings': 'සීමාවන් සුරකින්න',
      'save_success': 'ගාස්තු සීමාවන් සාර්ථකව සුරැකිණි',
      'manual_scanner': 'ස්ක්‍රීන්ෂොට් ස්කෑනරය',
      'manual_scanner_desc':
          'ගැලරියෙන් PickMe සවාරි කාඩ්පතේ ස්ක්‍රීන්ෂොට් එකක් තෝරා මැනුවල් ලෙස ගණනය කරන්න.',
      'select_image': 'රූපය තෝරන්න',
      'start_ocr_scan': 'OCR ස්කෑන් අරඹන්න',
      'scanning': 'පරිලෝකනය වේ...',
      'ocr_text_title': 'OCR අකුරු සටහන',
      'saved_trips_title': 'සුරැකි සවාරි',
      'no_saved_trips': 'තවමත් සවාරි සුරැකී නැත',
      'no_saved_trips_desc':
          'Auto scanner ක්‍රියාත්මක වන අතරතුර ඔබ පිළිගන්නා (Accept කරන) සවාරි මෙහි පෙන්වයි.',
      'clear_history_title': 'ඉතිහාසය මකන්නද?',
      'clear_history_body': 'සියලුම සුරැකි සවාරි ඉතිහාසය මකා දැමීමට අවශ්‍යද?',
      'cancel': 'අවලංගු කරන්න',
      'clear': 'මකන්න',
      'history_cleared': 'සවාරි ඉතිහාසය මකා දමන ලදී',
      'fare': 'ගාස්තුව',
      'total_dist': 'මුළු දුර',
      'trip_dist': 'සවාරිය',
      'pickup_dist': 'පිකප්',
      'error_loading_trip': 'සවාරි දත්ත දෝෂයකි',
    },
    'ta': {
      'app_title': 'FareRate',
      'auto_scan': 'ஸ்கேனர்',
      'manual_scan': 'ஸ்கிரீன்ஷாட்',
      'history': 'வரலாறு',
      'hello_driver': 'வணக்கம், ஓட்டுனர்!',
      'greeting_subtitle':
          'உங்கள் பிக்மீ கிலோமீட்டர் கட்டணத்தை கண்காணித்து உங்கள் வருவாயை அதிகரிக்கவும்.',
      'auto_scanner': 'தானியங்கி ஸ்கேனர்',
      'active': 'செயலில் உள்ளது',
      'inactive': 'செயலற்றது',
      'scanner_desc_active':
          'பயன்பாடு செயலில் உள்ளது. PickMe Driver செயலியை திறந்து வைக்கவும்; கட்டண Overlay தானாகவே தோன்றும்.',
      'scanner_desc_paused':
          'அணுகல்தன்மை இயக்கப்பட்டது, ஆனால் திரை வாசிப்பு தற்போது இடைநிறுத்தப்பட்டுள்ளது.',
      'scanner_desc_inactive':
          'உங்கள் திரையில் உள்ள கட்டணங்களை தானாகவே கண்டறிய அணுகல்தன்மை சேவையை இயக்கவும்.',
      'auto_screen_read': 'தானியங்கி திரை வாசிப்பு',
      'auto_screen_read_sub': 'திரைகளை தானாகவே வாசிக்கவும்',
      'auto_save_trips': 'பயணங்களை தானாக சேமிக்கவும்',
      'auto_save_trips_sub': 'நீங்கள் ஏற்கும்போது விவரங்களைச் சேமிக்கவும்',
      'enable_auto_popup': 'அணுகல்தன்மையை இயக்கவும்',
      'refresh_status': 'நிலையைப் புதுப்பிக்கவும்',
      'fare_threshold_settings': 'கட்டண வரம்பு அமைப்புகள்',
      'threshold_subtitle': 'LKR/km கட்டண வரம்பு வர்ணங்களை அமைக்கவும்',
      'low_threshold': 'குறைந்த வரம்பு',
      'high_threshold': 'உயர் வரம்பு',
      'save_settings': 'அமைப்புகளைச் சேமிக்கவும்',
      'save_success': 'கட்டண வரம்பு அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன',
      'manual_scanner': 'கைமுறை ஸ்கேனர்',
      'manual_scanner_desc':
          'கட்டணத்தை கைமுறையாக கணக்கிட உங்கள் கேலரியில் இருந்து பிக்மீ ஸ்கிரீன்ஷாட்டைத் தேர்ந்தெடுக்கவும்.',
      'select_image': 'படத்தைத் தேர்ந்தெடு',
      'start_ocr_scan': 'OCR ஸ்கேன் தொடங்கு',
      'scanning': 'ஸ்கேன் செய்யப்படுகிறது...',
      'ocr_text_title': 'OCR உரை',
      'saved_trips_title': 'சேமிக்கப்பட்ட பயணங்கள்',
      'no_saved_trips': 'இன்னும் பயணங்கள் சேமிக்கப்படவில்லை',
      'no_saved_trips_desc':
          'ஸ்கேனர் இயங்கும்போது ஏற்றுக்கொள்ளப்பட்ட பயணங்கள் தானாகவே இங்கு தோன்றும்.',
      'clear_history_title': 'வரலாற்றை அழிக்கவா?',
      'clear_history_body':
          'சேமிக்கப்பட்ட அனைத்து பயண வரலாற்றையும் அழிக்க விரும்புகிறீர்களா?',
      'cancel': 'ரத்துசெய்',
      'clear': 'அழி',
      'history_cleared': 'வரலாறு அழிக்கப்பட்டது',
      'fare': 'கட்டணம்',
      'total_dist': 'மொத்த தூரம்',
      'trip_dist': 'பயணம்',
      'pickup_dist': 'பிக்கப்',
      'error_loading_trip': 'பயண விவரங்களை ஏற்றுவதில் பிழை',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}

class TripCalculatorScreen extends ConsumerStatefulWidget {
  const TripCalculatorScreen({super.key});

  @override
  ConsumerState<TripCalculatorScreen> createState() =>
      _TripCalculatorScreenState();
}

class _TripCalculatorScreenState extends ConsumerState<TripCalculatorScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripCalculatorProvider);
    final notifier = ref.read(tripCalculatorProvider.notifier);
    final loc = AppLocalizations(state.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('app_title')),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.15),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: 'Language / භාෂාව / மொழி',
            onSelected: (lang) => notifier.setLanguage(lang),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'si', child: Text('සිංහල')),
              const PopupMenuItem(value: 'ta', child: Text('தமிழ்')),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: loc.translate('auto_scan'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.document_scanner_outlined),
            selectedIcon: const Icon(Icons.document_scanner),
            label: loc.translate('manual_scan'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: loc.translate('history'),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            _AutoScannerTab(),
            _ManualScannerTab(),
            _TripHistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _AutoScannerTab extends ConsumerWidget {
  const _AutoScannerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripCalculatorProvider);
    final notifier = ref.read(tripCalculatorProvider.notifier);
    final loc = AppLocalizations(state.languageCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.6),
                  Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('hello_driver'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.translate('greeting_subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          loc.translate('auto_scanner'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: state.isAutoPopupEnabled
                              ? Colors.green.withValues(alpha: 0.12)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: state.isAutoPopupEnabled
                                ? Colors.green.withValues(alpha: 0.3)
                                : Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state.isAutoPopupEnabled
                                    ? Colors.green
                                    : Colors.orange,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (state.isAutoPopupEnabled
                                                ? Colors.green
                                                : Colors.orange)
                                            .withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.isAutoPopupEnabled
                                  ? loc.translate('active')
                                  : loc.translate('inactive'),
                              style: TextStyle(
                                color: state.isAutoPopupEnabled
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.isAutoPopupEnabled
                        ? state.isAutoScanActive
                              ? loc.translate('scanner_desc_active')
                              : loc.translate('scanner_desc_paused')
                        : loc.translate('scanner_desc_inactive'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            loc.translate('auto_screen_read'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(loc.translate('auto_screen_read_sub')),
                          value:
                              state.isAutoPopupEnabled &&
                              state.isAutoScanActive,
                          onChanged: state.isAutoPopupEnabled
                              ? notifier.setAutoScanActive
                              : null,
                        ),
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.2),
                        ),
                        SwitchListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            loc.translate('auto_save_trips'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(loc.translate('auto_save_trips_sub')),
                          value:
                              state.isAutoPopupEnabled &&
                              state.isAutoSaveEnabled,
                          onChanged: state.isAutoPopupEnabled
                              ? notifier.setAutoSaveEnabled
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: notifier.openAutoPopupSettings,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.settings_accessibility),
                          label: Text(loc.translate('enable_auto_popup')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: notifier.refreshAutoPopupStatus,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        tooltip: loc.translate('refresh_status'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const ThresholdSettingsCard(),
        ],
      ),
    );
  }
}

class _ManualScannerTab extends ConsumerWidget {
  const _ManualScannerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripCalculatorProvider);
    final notifier = ref.read(tripCalculatorProvider.notifier);
    final loc = AppLocalizations(state.languageCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.document_scanner,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.translate('manual_scanner'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.translate('manual_scanner_desc'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: state.isScanning
                              ? null
                              : notifier.selectScreenshot,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.image),
                          label: Text(loc.translate('select_image')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed:
                              state.isScanning ||
                                  state.selectedImageFile == null
                              ? null
                              : notifier.scanSelectedScreenshot,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: state.isScanning
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.flash_on),
                          label: Text(
                            state.isScanning
                                ? loc.translate('scanning')
                                : loc.translate('start_ocr_scan'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (state.selectedImageFile != null) ...[
            const SizedBox(height: 16),
            ScreenshotPreview(imageFile: state.selectedImageFile),
          ],
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            _MessageCard(
              message: state.errorMessage!,
              icon: Icons.error_outline,
              color: Theme.of(context).colorScheme.errorContainer,
            ),
          ],
          if (state.warningMessage != null) ...[
            const SizedBox(height: 16),
            _MessageCard(
              message: state.warningMessage!,
              icon: Icons.warning_amber,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ],
          if (state.tripData != null) ...[
            const SizedBox(height: 16),
            ResultCard(state: state),
          ],
          if (state.rawOcrText != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('ocr_text_title'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(state.rawOcrText!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TripHistoryTab extends ConsumerWidget {
  const _TripHistoryTab();

  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$month-$day $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripCalculatorProvider);
    final notifier = ref.read(tripCalculatorProvider.notifier);
    final loc = AppLocalizations(state.languageCode);

    if (state.savedTrips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_toggle_off,
                size: 72,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 18),
              Text(
                loc.translate('no_saved_trips'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('no_saved_trips_desc'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.translate('saved_trips_title'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(loc.translate('clear_history_title')),
                  content: Text(loc.translate('clear_history_body')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(loc.translate('cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        notifier.clearSavedTrips();
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.translate('history_cleared')),
                          ),
                        );
                      },
                      child: Text(
                        loc.translate('clear'),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            tooltip: loc.translate('clear'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.savedTrips.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final jsonStr = state.savedTrips[index];
          try {
            final data = Map<String, dynamic>.from(json.decode(jsonStr) as Map);
            final fare = (data['fareAmount'] as num).toDouble();
            final pickup = (data['pickupDistance'] as num).toDouble();
            final tripDist = (data['tripDistance'] as num).toDouble();
            final totalDist = (data['totalDistance'] as num).toDouble();
            final perKm = (data['perKmPrice'] as num).toDouble();
            final timestamp = (data['timestamp'] as num).toInt();

            final rateColor = perKm < state.lowThreshold
                ? Colors.red.shade600
                : perKm >= state.highThreshold
                ? Colors.green.shade600
                : Colors.orange.shade700;

            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: rateColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: rateColor.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${NumberFormatter.twoDecimals(perKm)} LKR/km',
                            style: TextStyle(
                              color: rateColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(timestamp),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TripDetailItem(
                            label: loc.translate('fare'),
                            value: '${NumberFormatter.twoDecimals(fare)} LKR',
                          ),
                        ),
                        Expanded(
                          child: _TripDetailItem(
                            label: loc.translate('total_dist'),
                            value:
                                '${NumberFormatter.twoDecimals(totalDist)} km',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _TripDetailItem(
                            label: loc.translate('trip_dist'),
                            value:
                                '${NumberFormatter.twoDecimals(tripDist)} km',
                          ),
                        ),
                        Expanded(
                          child: _TripDetailItem(
                            label: loc.translate('pickup_dist'),
                            value: '${NumberFormatter.twoDecimals(pickup)} km',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } catch (e) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  loc.translate('error_loading_trip'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.icon,
    required this.color,
  });

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class ThresholdSettingsCard extends ConsumerStatefulWidget {
  const ThresholdSettingsCard({super.key});

  @override
  ConsumerState<ThresholdSettingsCard> createState() =>
      _ThresholdSettingsCardState();
}

class _ThresholdSettingsCardState extends ConsumerState<ThresholdSettingsCard> {
  late final TextEditingController _lowController;
  late final TextEditingController _highController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(tripCalculatorProvider);
    _lowController = TextEditingController(
      text: state.lowThreshold.toStringAsFixed(0),
    );
    _highController = TextEditingController(
      text: state.highThreshold.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _lowController.dispose();
    _highController.dispose();
    super.dispose();
  }

  void _save() {
    final low = double.tryParse(_lowController.text) ?? 50.0;
    final high = double.tryParse(_highController.text) ?? 100.0;
    ref.read(tripCalculatorProvider.notifier).updateThresholds(low, high);

    final state = ref.read(tripCalculatorProvider);
    final loc = AppLocalizations(state.languageCode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.translate('save_success')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripCalculatorProvider);
    final loc = AppLocalizations(state.languageCode);

    ref.listen<TripCalculatorState>(tripCalculatorProvider, (previous, next) {
      if (previous == null || previous.lowThreshold != next.lowThreshold) {
        _lowController.text = next.lowThreshold.toStringAsFixed(0);
      }
      if (previous == null || previous.highThreshold != next.highThreshold) {
        _highController.text = next.highThreshold.toStringAsFixed(0);
      }
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.color_lens,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.translate('fare_threshold_settings'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              loc.translate('threshold_subtitle'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lowController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: loc.translate('low_threshold'),
                      suffixText: 'LKR',
                      prefixIcon: const Icon(
                        Icons.arrow_downward,
                        color: Colors.red,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _highController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: loc.translate('high_threshold'),
                      suffixText: 'LKR',
                      prefixIcon: const Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: Text(loc.translate('save_settings')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripDetailItem extends StatelessWidget {
  const _TripDetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
