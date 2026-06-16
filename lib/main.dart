import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/trip_calculator/data/services/auto_scan_permission_service.dart';
import 'features/trip_calculator/presentation/providers/trip_calculator_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final lang = await AutoScanPermissionService().getLanguage();
    TripCalculatorState.initialLanguage = lang;
  } catch (_) {}
  runApp(const ProviderScope(child: PickMePerKmCalculatorApp()));
}
