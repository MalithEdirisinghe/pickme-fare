class NumberFormatter {
  const NumberFormatter._();

  static String twoDecimals(double value) => value.toStringAsFixed(2);

  static double? parseOcrNumber(String value) {
    final normalized = value.trim();

    if (normalized.contains(',') && normalized.contains('.')) {
      return double.tryParse(normalized.replaceAll(',', ''));
    }
    if (RegExp(r'^\d{1,3}(?:,\d{3})+$').hasMatch(normalized)) {
      return double.tryParse(normalized.replaceAll(',', ''));
    }

    return double.tryParse(normalized.replaceAll(',', '.'));
  }
}
