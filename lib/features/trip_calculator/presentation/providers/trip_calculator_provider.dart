import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/auto_scan_permission_service.dart';
import '../../data/services/ocr_service.dart';
import '../../domain/entities/trip_calculation_result.dart';
import '../../domain/entities/trip_request_data.dart';
import '../../domain/usecases/calculate_per_km_usecase.dart';
import '../../domain/usecases/extract_trip_data_usecase.dart';

final tripCalculatorProvider =
    NotifierProvider<TripCalculatorNotifier, TripCalculatorState>(
      TripCalculatorNotifier.new,
    );

class TripCalculatorState {
  static String initialLanguage = 'si';

  TripCalculatorState({
    this.selectedImageFile,
    this.isScanning = false,
    this.rawOcrText,
    this.tripData,
    this.calculationResult,
    this.errorMessage,
    this.isAutoPopupEnabled = false,
    this.isAutoScanActive = true,
    this.lowThreshold = 50.0,
    this.highThreshold = 100.0,
    this.isAutoSaveEnabled = false,
    this.savedTrips = const [],
    String? languageCode,
  }) : languageCode = languageCode ?? initialLanguage;

  final File? selectedImageFile;
  final bool isScanning;
  final String? rawOcrText;
  final TripRequestData? tripData;
  final TripCalculationResult? calculationResult;
  final String? errorMessage;
  final bool isAutoPopupEnabled;
  final bool isAutoScanActive;
  final double lowThreshold;
  final double highThreshold;
  final bool isAutoSaveEnabled;
  final List<String> savedTrips;
  final String languageCode;

  double? get fareAmount => tripData?.fareAmount;
  double? get pickupDistance => tripData?.pickupDistance;
  double? get tripDistance => tripData?.tripDistance;
  double? get totalDistance => calculationResult?.totalDistance;
  double? get perKmPrice => calculationResult?.perKmPrice;
  String? get warningMessage => tripData?.warningMessage;

  TripCalculatorState copyWith({
    File? selectedImageFile,
    bool? isScanning,
    String? rawOcrText,
    TripRequestData? tripData,
    TripCalculationResult? calculationResult,
    String? errorMessage,
    bool? isAutoPopupEnabled,
    bool? isAutoScanActive,
    double? lowThreshold,
    double? highThreshold,
    bool? isAutoSaveEnabled,
    List<String>? savedTrips,
    String? languageCode,
    bool clearScanData = false,
    bool clearError = false,
  }) {
    return TripCalculatorState(
      selectedImageFile: selectedImageFile ?? this.selectedImageFile,
      isScanning: isScanning ?? this.isScanning,
      rawOcrText: clearScanData ? null : rawOcrText ?? this.rawOcrText,
      tripData: clearScanData ? null : tripData ?? this.tripData,
      calculationResult: clearScanData
          ? null
          : calculationResult ?? this.calculationResult,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isAutoPopupEnabled: isAutoPopupEnabled ?? this.isAutoPopupEnabled,
      isAutoScanActive: isAutoScanActive ?? this.isAutoScanActive,
      lowThreshold: lowThreshold ?? this.lowThreshold,
      highThreshold: highThreshold ?? this.highThreshold,
      isAutoSaveEnabled: isAutoSaveEnabled ?? this.isAutoSaveEnabled,
      savedTrips: savedTrips ?? this.savedTrips,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class TripCalculatorNotifier extends Notifier<TripCalculatorState> {
  final ImagePicker _imagePicker = ImagePicker();
  final AutoScanPermissionService _autoScanPermissionService =
      AutoScanPermissionService();
  final OcrService _ocrService = OcrService();
  final ExtractTripDataUseCase _extractTripDataUseCase =
      ExtractTripDataUseCase();
  final CalculatePerKmUseCase _calculatePerKmUseCase = CalculatePerKmUseCase();

  @override
  TripCalculatorState build() {
    Future.microtask(() {
      refreshAutoPopupStatus();
      refreshThresholds();
      refreshAutoSaveStatus();
      refreshSavedTrips();
      refreshLanguage();
    });
    return TripCalculatorState();
  }

  Future<void> openAutoPopupSettings() async {
    await _autoScanPermissionService.openAccessibilitySettings();
  }

  Future<void> refreshAutoPopupStatus() async {
    final isEnabled = await _autoScanPermissionService.isAccessibilityEnabled();
    final isActive = await _autoScanPermissionService.isAutoScanActive();
    state = state.copyWith(
      isAutoPopupEnabled: isEnabled,
      isAutoScanActive: isActive,
    );
  }

  Future<void> setAutoScanActive(bool isActive) async {
    await _autoScanPermissionService.setAutoScanActive(isActive);
    state = state.copyWith(isAutoScanActive: isActive);
  }

  Future<void> refreshThresholds() async {
    final thresholds = await _autoScanPermissionService.getThresholds();
    state = state.copyWith(
      lowThreshold: thresholds['low'],
      highThreshold: thresholds['high'],
    );
  }

  Future<void> updateThresholds(double low, double high) async {
    await _autoScanPermissionService.setThresholds(low, high);
    state = state.copyWith(
      lowThreshold: low,
      highThreshold: high,
    );
  }

  Future<void> refreshAutoSaveStatus() async {
    final isEnabled = await _autoScanPermissionService.isAutoSaveEnabled();
    state = state.copyWith(isAutoSaveEnabled: isEnabled);
  }

  Future<void> setAutoSaveEnabled(bool isEnabled) async {
    await _autoScanPermissionService.setAutoSaveEnabled(isEnabled);
    state = state.copyWith(isAutoSaveEnabled: isEnabled);
  }

  Future<void> refreshSavedTrips() async {
    final trips = await _autoScanPermissionService.getSavedTrips();
    state = state.copyWith(savedTrips: trips);
  }

  Future<void> clearSavedTrips() async {
    await _autoScanPermissionService.clearSavedTrips();
    state = state.copyWith(savedTrips: const []);
  }

  Future<void> refreshLanguage() async {
    final lang = await _autoScanPermissionService.getLanguage();
    state = state.copyWith(languageCode: lang);
  }

  Future<void> setLanguage(String language) async {
    await _autoScanPermissionService.setLanguage(language);
    state = state.copyWith(languageCode: language);
  }

  Future<void> selectScreenshot() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    state = state.copyWith(
      selectedImageFile: File(image.path),
      clearScanData: true,
      clearError: true,
    );
  }

  Future<void> scanSelectedScreenshot() async {
    final selectedImageFile = state.selectedImageFile;
    if (selectedImageFile == null) {
      state = state.copyWith(errorMessage: 'Please select a screenshot first.');
      return;
    }

    state = state.copyWith(isScanning: true, clearError: true);

    try {
      final rawText = await _ocrService.recognizeText(selectedImageFile.path);
      final tripData = _extractTripDataUseCase(rawText);
      final calculationResult = _calculatePerKmUseCase(tripData);

      state = state.copyWith(
        isScanning: false,
        rawOcrText: rawText,
        tripData: tripData,
        calculationResult: calculationResult,
      );
    } on FormatException catch (error) {
      state = state.copyWith(isScanning: false, errorMessage: error.message);
    } on ArgumentError catch (error) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: error.message.toString(),
      );
    } catch (_) {
      state = state.copyWith(
        isScanning: false,
        errorMessage:
            'Could not scan this image. Try a clearer screenshot where the fare and km values are visible.',
      );
    }
  }
}
