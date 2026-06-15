import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/trip_calculator_provider.dart';
import '../widgets/result_card.dart';
import '../widgets/screenshot_preview.dart';

class TripCalculatorScreen extends ConsumerWidget {
  const TripCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripCalculatorProvider);
    final notifier = ref.read(tripCalculatorProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PickMe Per KM Calculator'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            state.isAutoPopupEnabled
                                ? Icons.check_circle
                                : Icons.pending_actions,
                            color: state.isAutoPopupEnabled
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Auto Popup Scanner',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.isAutoPopupEnabled
                            ? state.isAutoScanActive
                                  ? 'Enabled. Open PickMe Driver and keep the hire card visible. The per-km popup will appear automatically when fare and km values are detected.'
                                  : 'Accessibility is enabled, but auto screen reading is currently turned off.'
                            : 'Enable Accessibility once. This app only reads visible screen text/OCR and shows the per-km overlay; it does not control PickMe Driver.',
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Auto screen read'),
                        subtitle: const Text('Show per-km popup automatically'),
                        value:
                            state.isAutoPopupEnabled && state.isAutoScanActive,
                        onChanged: state.isAutoPopupEnabled
                            ? notifier.setAutoScanActive
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: notifier.openAutoPopupSettings,
                              icon: const Icon(Icons.settings_accessibility),
                              label: const Text('Enable Auto Popup'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filledTonal(
                            onPressed: notifier.refreshAutoPopupStatus,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh status',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const ThresholdSettingsCard(),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: state.isScanning
                              ? null
                              : notifier.selectScreenshot,
                          icon: const Icon(Icons.image),
                          label: const Text('Select Screenshot'),
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
                          icon: state.isScanning
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.document_scanner),
                          label: Text(state.isScanning ? 'Scanning' : 'Scan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ScreenshotPreview(imageFile: state.selectedImageFile),
              const SizedBox(height: 16),
              if (state.errorMessage != null) ...[
                _MessageCard(
                  message: state.errorMessage!,
                  icon: Icons.error_outline,
                  color: Theme.of(context).colorScheme.errorContainer,
                ),
                const SizedBox(height: 12),
              ],
              if (state.warningMessage != null) ...[
                _MessageCard(
                  message: state.warningMessage!,
                  icon: Icons.warning_amber,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                const SizedBox(height: 12),
              ],
              ResultCard(state: state),
              if (state.rawOcrText != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OCR Text',
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
        ),
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
  ConsumerState<ThresholdSettingsCard> createState() => _ThresholdSettingsCardState();
}

class _ThresholdSettingsCardState extends ConsumerState<ThresholdSettingsCard> {
  late final TextEditingController _lowController;
  late final TextEditingController _highController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(tripCalculatorProvider);
    _lowController = TextEditingController(text: state.lowThreshold.toStringAsFixed(0));
    _highController = TextEditingController(text: state.highThreshold.toStringAsFixed(0));
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Threshold settings saved successfully / සීමාවන් සාර්ථකව සුරැකිණි'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.color_lens,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Fare Threshold Settings',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'සවාරි ගාස්තු වර්ණ සීමාවන් සකසන්න (LKR/km)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lowController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Low / අඩු සීමාව',
                      suffixText: 'LKR',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _highController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'High / වැඩි සීමාව',
                      suffixText: 'LKR',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.arrow_upward, color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Settings / සුරකින්න'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
