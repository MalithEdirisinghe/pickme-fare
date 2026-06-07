class TripRequestData {
  const TripRequestData({
    required this.fareAmount,
    required this.pickupDistance,
    required this.tripDistance,
    this.warningMessage,
  });

  final double fareAmount;
  final double pickupDistance;
  final double tripDistance;
  final String? warningMessage;
}
