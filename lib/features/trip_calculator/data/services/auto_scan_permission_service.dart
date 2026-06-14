import 'package:flutter/services.dart';

class AutoScanPermissionService {
  static const MethodChannel _channel = MethodChannel(
    'pickme_per_km_calculator/auto_scan',
  );

  Future<void> openAccessibilitySettings() async {
    await _channel.invokeMethod<void>('openAccessibilitySettings');
  }

  Future<bool> isAccessibilityEnabled() async {
    final isEnabled = await _channel.invokeMethod<bool>(
      'isAccessibilityEnabled',
    );
    return isEnabled ?? false;
  }

  Future<bool> isAutoScanActive() async {
    final isActive = await _channel.invokeMethod<bool>('isAutoScanActive');
    return isActive ?? true;
  }

  Future<void> setAutoScanActive(bool isActive) async {
    await _channel.invokeMethod<void>('setAutoScanActive', {
      'isActive': isActive,
    });
  }
}
