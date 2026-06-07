import 'package:flutter/material.dart';

import '../../../../../core/utils/number_formatter.dart';
import '../providers/trip_calculator_provider.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.state});

  final TripCalculatorState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Per KM Price',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              state.perKmPrice == null
                  ? '-- LKR/km'
                  : '${NumberFormatter.twoDecimals(state.perKmPrice!)} LKR/km',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 28),
            _ResultRow(
              label: 'Fare Amount',
              sinhalaLabel: 'ගාස්තුව',
              value: state.fareAmount == null
                  ? '--'
                  : '${NumberFormatter.twoDecimals(state.fareAmount!)} LKR',
            ),
            _ResultRow(
              label: 'Pickup Distance',
              sinhalaLabel: 'Pickup දුර',
              value: state.pickupDistance == null
                  ? '--'
                  : '${NumberFormatter.twoDecimals(state.pickupDistance!)} km',
            ),
            _ResultRow(
              label: 'Trip Distance',
              sinhalaLabel: 'Trip දුර',
              value: state.tripDistance == null
                  ? '--'
                  : '${NumberFormatter.twoDecimals(state.tripDistance!)} km',
            ),
            _ResultRow(
              label: 'Total Distance',
              sinhalaLabel: 'මුළු දුර',
              value: state.totalDistance == null
                  ? '--'
                  : '${NumberFormatter.twoDecimals(state.totalDistance!)} km',
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.sinhalaLabel,
    required this.value,
  });

  final String label;
  final String sinhalaLabel;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$label\n$sinhalaLabel',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
