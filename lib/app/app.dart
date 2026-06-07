import 'package:flutter/material.dart';

import '../features/trip_calculator/presentation/screens/trip_calculator_screen.dart';

class PickMePerKmCalculatorApp extends StatelessWidget {
  const PickMePerKmCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PickMe Per KM Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5B400),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F2),
      ),
      home: const TripCalculatorScreen(),
    );
  }
}
