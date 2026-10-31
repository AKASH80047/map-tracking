import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_tracking/models/location_point.dart';
import 'package:map_tracking/models/trip_model.dart';
import 'package:map_tracking/models/vehicle_type.dart';
import 'package:map_tracking/services/location_service.dart';

void main() {
  group('LocationService Math & Calculations', () {
    test('calculateDistanceMeters calculates accurate distance', () {
      // 1 degree latitude is approx 111,000 meters
      const p1 = LatLng(37.7749, -122.4194);
      const p2 = LatLng(37.7759, -122.4194);

      final distance = LocationService.calculateDistanceMeters(p1, p2);
      expect(distance, greaterThan(100));
      expect(distance, lessThan(125));
    });

    test('calculateBearing calculates northward bearing ~0 degrees', () {
      const p1 = LatLng(37.7749, -122.4194);
      const p2 = LatLng(37.7849, -122.4194); // directly North

      final bearing = LocationService.calculateBearing(p1, p2);
      expect(bearing, closeTo(0.0, 1.0));
    });

    test('calculateBearing calculates eastward bearing ~90 degrees', () {
      const p1 = LatLng(37.7749, -122.4194);
      const p2 = LatLng(37.7749, -122.4094); // directly East

      final bearing = LocationService.calculateBearing(p1, p2);
      expect(bearing, closeTo(90.0, 1.0));
    });
  });

  group('TripModel Formatting and Logic', () {
    test('progress percentage calculates correctly', () {
      final trip = TripModel(
        id: 'test_1',
        startAddress: 'Start',
        startLocation: const LatLng(37.77, -122.41),
        destinationName: 'End',
        destinationAddress: 'End Address',
        destinationLocation: const LatLng(37.78, -122.40),
        vehicleType: VehicleType.bike,
        startTime: DateTime.now(),
        currentLocation: LocationPoint(position: const LatLng(37.77, -122.41)),
        routePoints: const [LatLng(37.77, -122.41), LatLng(37.78, -122.40)],
        totalPlannedDistanceMeters: 5000.0,
        distanceTravelledMeters: 3200.0,
        distanceRemainingMeters: 1800.0,
        estimatedRemainingDuration: const Duration(minutes: 5),
        currentSpeedKmh: 42.0,
        averageSpeedKmh: 38.0,
        maxSpeedKmh: 45.0,
      );

      expect(trip.progressPercentage, closeTo(0.64, 0.01));
      expect(trip.progressPercentInt, equals(64));
      expect(trip.formattedTravelledDistance, equals('3.2 km'));
      expect(trip.formattedRemainingDistance, equals('1.8 km'));
      expect(trip.formattedTotalDistance, equals('5.0 km'));
      expect(trip.formattedRemainingTime, equals('5 min'));
    });
  });
}

