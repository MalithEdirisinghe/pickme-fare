import '../entities/trip_calculation_result.dart';
import '../entities/trip_request_data.dart';

class CalculatePerKmUseCase {
  TripCalculationResult call(TripRequestData data) {
    final totalDistance = data.pickupDistance + data.tripDistance;
    if (totalDistance <= 0) {
      throw ArgumentError('Total distance must be greater than zero.');
    }

    return TripCalculationResult(
      totalDistance: totalDistance,
      perKmPrice: data.fareAmount / totalDistance,
    );
  }
}
