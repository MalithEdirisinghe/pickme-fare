class NumberFormatter {
  const NumberFormatter._();

  static String twoDecimals(double value) => value.toStringAsFixed(2);

  static double? parseOcrNumber(String value) {
    return double.tryParse(value.replaceAll(',', '.'));
  }
}
