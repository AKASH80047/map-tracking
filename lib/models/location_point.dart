import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPoint {
  final LatLng position;
  final double heading;
  final double speedKmh;
  final double accuracy;
  final DateTime timestamp;

  LocationPoint({
    required this.position,
    this.heading = 0.0,
    this.speedKmh = 0.0,
    this.accuracy = 0.0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  LocationPoint copyWith({
    LatLng? position,
    double? heading,
    double? speedKmh,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return LocationPoint(
      position: position ?? this.position,
      heading: heading ?? this.heading,
      speedKmh: speedKmh ?? this.speedKmh,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

