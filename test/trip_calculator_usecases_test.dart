import 'package:flutter_test/flutter_test.dart';
import 'package:pickme_per_km_calculator/features/trip_calculator/domain/usecases/calculate_per_km_usecase.dart';
import 'package:pickme_per_km_calculator/features/trip_calculator/domain/usecases/extract_trip_data_usecase.dart';

void main() {
  test('extracts sample PickMe text and calculates per km price', () {
    const text = '''
172.32 LKR
2mins away, 0.6 km
7 min, 2.34 km
''';

    final tripData = ExtractTripDataUseCase().call(text);
    final result = CalculatePerKmUseCase().call(tripData);

    expect(tripData.fareAmount, 172.32);
    expect(tripData.pickupDistance, 0.6);
    expect(tripData.tripDistance, 2.34);
    expect(result.totalDistance.toStringAsFixed(2), '2.94');
    expect(result.perKmPrice.toStringAsFixed(2), '58.61');
  });

  test('uses the first two km values and warns when extra distances exist', () {
    const text = '172 LKR 0.6 km 2.34 km 4.5 km';

    final tripData = ExtractTripDataUseCase().call(text);

    expect(tripData.pickupDistance, 0.6);
    expect(tripData.tripDistance, 2.34);
    expect(tripData.warningMessage, isNotNull);
  });
}
