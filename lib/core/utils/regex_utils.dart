class RegexUtils {
  const RegexUtils._();

  static final RegExp farePattern = RegExp(
    r'((?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?|\d+(?:,\d+)?)\s*(?:lkr|rs\.?)',
    caseSensitive: false,
  );

  static final RegExp distancePattern = RegExp(
    r'((?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?|\d+(?:,\d+)?)\s*(?:km|kms|kilometer|kilometers)\b',
    caseSensitive: false,
  );
}
