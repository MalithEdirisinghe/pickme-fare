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

  Future<Map<String, double>> getThresholds() async {
    final Map? result = await _channel.invokeMethod<Map>('getThresholds');
    if (result == null) return {'low': 50.0, 'high': 100.0};
    return {
      'low': (result['low'] as num).toDouble(),
      'high': (result['high'] as num).toDouble(),
    };
  }

  Future<void> setThresholds(double low, double high) async {
    await _channel.invokeMethod<void>('setThresholds', {
      'low': low,
      'high': high,
    });
  }

  Future<List<String>> getSavedTrips() async {
    final List? result = await _channel.invokeMethod<List>('getSavedTrips');
    if (result == null) return const [];
    return result.cast<String>();
  }

  Future<void> clearSavedTrips() async {
    await _channel.invokeMethod<void>('clearSavedTrips');
  }

  Future<bool> isAutoSaveEnabled() async {
    final isEnabled = await _channel.invokeMethod<bool>('isAutoSaveEnabled');
    return isEnabled ?? false;
  }

  Future<void> setAutoSaveEnabled(bool isEnabled) async {
    await _channel.invokeMethod<void>('setAutoSaveEnabled', {
      'isEnabled': isEnabled,
    });
  }

  Future<String> getLanguage() async {
    final String? lang = await _channel.invokeMethod<String>('getLanguage');
    return lang ?? 'en';
  }

  Future<void> setLanguage(String language) async {
    await _channel.invokeMethod<void>('setLanguage', {
      'language': language,
    });
  }
}
