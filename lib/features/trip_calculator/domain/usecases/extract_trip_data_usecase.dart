import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/regex_utils.dart';
import '../entities/trip_request_data.dart';

class ExtractTripDataUseCase {
  TripRequestData call(String text) {
    final fareAmount = _extractFare(text);
    final distances = _extractDistances(text);

    if (fareAmount == null) {
      throw const FormatException('Fare amount could not be detected.');
    }
    if (distances.length < 2) {
      throw const FormatException(
        'Pickup and trip distances could not be detected.',
      );
    }

    return TripRequestData(
      fareAmount: fareAmount,
      pickupDistance: distances[0],
      tripDistance: distances[1],
      warningMessage: distances.length > 2
          ? 'More than two km values were detected. Using the first two.'
          : null,
    );
  }

  double? _extractFare(String text) {
    // Finds fare formats like "172.32 LKR" or "172 LKR".
    // The LKR/Rs token anchors the number so OCR text such as minutes or km
    // values are not accidentally treated as the fare amount.
    final match = RegexUtils.farePattern.firstMatch(text);
    if (match == null) {
      return null;
    }

    return NumberFormatter.parseOcrNumber(match.group(1)!);
  }

  List<double> _extractDistances(String text) {
    // Finds every distance number followed by km/kms/kilometer, including:
    // "0.6 km", "7 min, 2.34 km", and "2mins away, 0.6 km".
    return RegexUtils.distancePattern
        .allMatches(text)
        .map((match) => NumberFormatter.parseOcrNumber(match.group(1)!))
        .whereType<double>()
        .toList();
  }
}
