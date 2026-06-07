class RegexUtils {
  const RegexUtils._();

  static final RegExp farePattern = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(?:lkr|rs\.?|රු)',
    caseSensitive: false,
  );

  static final RegExp distancePattern = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(?:km|kms|kilometer|kilometers)\b',
    caseSensitive: false,
  );
}
