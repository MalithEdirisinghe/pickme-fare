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
