import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  const TripCalculatorState({
    this.selectedImageFile,
    this.isScanning = false,
    this.rawOcrText,
    this.tripData,
    this.calculationResult,
    this.errorMessage,
  });

  final File? selectedImageFile;
  final bool isScanning;
  final String? rawOcrText;
  final TripRequestData? tripData;
  final TripCalculationResult? calculationResult;
  final String? errorMessage;

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
    );
  }
}

class TripCalculatorNotifier extends Notifier<TripCalculatorState> {
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final ExtractTripDataUseCase _extractTripDataUseCase =
      ExtractTripDataUseCase();
  final CalculatePerKmUseCase _calculatePerKmUseCase = CalculatePerKmUseCase();

  @override
  TripCalculatorState build() {
    return const TripCalculatorState();
  }

  Future<void> selectScreenshot() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    state = TripCalculatorState(selectedImageFile: File(image.path));
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
